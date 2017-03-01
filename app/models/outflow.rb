class Outflow < ActiveRecord::Base
  has_paper_trail
  mount_uploader :file, FileUploader

  # Constantes
  KIND = {
    upfront:      'u',
    to_favor:     'f',
    refunded:     'r',
    maintenance:  'm',
    payoff:       'x',
    other:        'o',
    cetem_gral:   'c',
    cca_gral:     'g',
    library:      'l',
    tops_rings:   'q',
    paper:        'p',
    toner:        't'
  }.with_indifferent_access.freeze
  NO_OPERATOR_KINDS = KIND.except(*%w(upfront to_favor refunded payoff))

  # Scopes
  scope :upfronts, -> { where(kind: KIND[:upfront]) }
  scope :to_favor, -> { where(kind: KIND[:to_favor]) }
  scope :credits, -> { where(kind: [KIND[:upfront], KIND[:to_favor]]) }
  scope :of_operators, -> { where.not(operator_id: nil) }
  scope :for_operator, -> (operator) { where(operator_id: operator) }
  scope :filtered_by, -> (q) { q.present? ? where(kind: KIND[q]) : all }
  scope :at_month, -> (date) { where(bought_at: date.beginning_of_month..date.end_of_month) }

  # Attributos no persistentes
  attr_accessor :auto_operator_name

  # Validaciones
  validates :amount, :kind, :user_id, presence: true
  validates :amount, numericality: { allow_nil: true, allow_blank: true,
    greater_than: 0.00 }, if: -> (o) { !o.kind_is_payoff? }
  validates :amount, numericality: { allow_nil: true, allow_blank: true },
    if: -> (o) { o.kind_is_payoff? }
  validates :operator_id, presence: true, if: :operator_needed?
  validates :comment, presence: true, if: :kind_is_other?
  validates :provider, presence: true, if: -> (o) { o.bill.present? }
  validates :bill, presence: true, if: -> (o) { o.billeable? }

  # Relaciones
  belongs_to :user

  KIND.each do |kind, value|
    define_method("kind_is_#{kind}?") { self.kind == KIND[kind] }
  end


  def self.headers_for(date)
    translated_date = I18n.l(date, format: :to_month).camelize

    header = non_operator_headers_for(date, translated_date)
    header << operator_headers_for(date, translated_date)
    header
  end

  def self.non_operator_headers_for(date, translated_date)
    NO_OPERATOR_KINDS.map do |k, v|
      _scope = where(kind: v).at_month(date).map(&:to_info)

      if _scope.count > 0
        amount = _scope.sum { |r| r[2] }

        _scope << [nil, nil, amount]
        title = I18n.t('view.outflows.kind.' + k)

        [_scope, [translated_date, title]]
      end
    end.compact
  end

  def self.operator_headers_for(date, translated_date)
    date_range = date.to_datetime.beginning_of_month..date.to_datetime.end_of_month
    title =  I18n.t('view.outflows.operators')
    kinds =  %w(upfront to_favor refunded payoff).map { |k| KIND[k] }

    _scope = where(kind: kinds, created_at: date_range)

    operator_ids = _scope.map(&:operator_id).uniq.compact
    total = 0.0

    data = operator_ids.map do |id|
      operator_scope = _scope.where(operator_id: id)
      operator_amount = operator_scope.sum(:amount).round(2)
      total += operator_amount

      [
        nil,
        nil,
        operator_amount,
        operator_scope.first.operator_name
      ]
    end

    data << [nil, nil, total]

    [data, [translated_date, title]]
  end

  def self.to_monthly_info(date)
    #require 'csv'

    table_header = %w(date bill amount provider details).map do |k|
      I18n.t('view.outflows.reports.' + k)
    end
    csv = []
    #CSV.generate do |csv|
    headers_for(date).each do |_scope, head|
      csv << []
      csv << head
      csv << table_header
      _scope.each { |info| csv << info }
      csv << []
    end
    csv
  end

  def to_info
    [
      I18n.l(self.bought_at || self.created_at.to_date),
      bill,
      amount.round(2),
      provider,
      comment
    ]
  end

  def billeable?
    kind_is_library? || kind_is_tops_rings? || kind_is_paper? || kind_is_toner? ||
      kind_is_maintenance?
  end

  def operator_needed?
    self.kind.present? && !NO_OPERATOR_KINDS.values.include?(self.kind)
  end

  def kind_symbol
    KIND.invert[self.kind]
  end

  def self.shifts_info(shifts)
    operator = shifts['operator']
    operator_hours = operator ? operator['hours'].to_f : 0.0
    admin = shifts['admin']
    admin_hours = admin ? admin['hours'].to_f : 0.0
    hours = operator_hours + admin_hours

    _count = (
      (operator ? operator['count'].to_i : 0) +
      (admin ? admin['count'].to_i : 0)
    )
    amount = (
      operator_hours * Setting.price_for_operator +
      admin_hours * Setting.price_for_admin
    ).round(2)

    suspicious_shifts = operator['suspicious_shifts'] if operator
    if !suspicious_shifts && admin
      suspicious_shifts = admin['suspicious_shifts']
    end

    OpenStruct.new(
      hours: hours, amount: amount, count: _count,
      suspicious_shifts: suspicious_shifts
    )
  end

  def self.operators_pay_pending_shifts_between(start, finish)
    data = Operator.get(
      :pay_pending_shifts_for_active_users_between,
      start: start, finish: finish
    )

    data.map do |user_data|
      user = user_data['user']
      _shifts_info = shifts_info(user_data['shifts'])

      OpenStruct.new(
        operator: OpenStruct.new(
          id: user['id'],
          label: user['label'],
          credit: credit_for_operator(user['id'])
        ),
        shifts: _shifts_info
      )
    end
  end

  def refund!
    self.update_attributes(kind: KIND[:refunded])
  end

  def self.pay_operator_shifts_and_upfronts(options = {})
    Outflow.transaction do
      begin
        operator_id = options[:operator_id]

        Operator.find(options[:operator_id]).patch(
          :pay_shifts_between, start: options[:start], finish: options[:finish]
        )

        raise unless Outflow.credits.where(operator_id: operator_id).all?(&:refund!)

        pay = Outflow.create!(
          kind: KIND[:payoff],
          start_shift: Date.parse(options[:start]),
          finish_shift: Date.parse(options[:finish]),
          amount: options[:amount].to_f.abs,
          user_id: options[:user_id],
          operator_id: operator_id,
          with_incentive: options[:with_incentive],
          bought_at: Date.today,
          charged_by: options[:charged_by]
        )

        upfront = options[:upfronts].to_f

        if upfront != 0 && !options[:with_incentive]
          Outflow.create!(
            kind: (upfront < 0 ? KIND[:to_favor] : KIND[:upfront]),
            amount: upfront.abs,
            comment: I18n.t(
              'view.outflows.reajust_of',
              id: pay.id,
              path: Rails.application.routes.url_helpers.outflow_path(pay)
            ),
            user_id: options[:user_id],
            operator_id: operator_id,
            bought_at: Date.today,
            charged_by: options[:charged_by]
          )
        end
      rescue
        raise ActiveRecord::Rollback
      end

      true
    end
  end

  def operator_name
    if self.operator_id
      begin
        Operator.find(self.operator_id).try(:label)
      rescue
        'Unknown'
      end
    else
      ''
    end
  end

  def self.credit_for_operator(operator)
    operator_outflows = Outflow.where(operator_id: operator)

    (
      operator_outflows.to_favor.sum(:amount) -
      operator_outflows.upfronts.sum(:amount)
    )
  end
end
