module Movements::Reports
  extend ActiveSupport::Concern

  def to_info
    [
      I18n.l(self.bought_at || self.created_at.to_date),
      bill,
      amount.round(2),
      to_account&.name || '',
      comment
    ]
  end

  class_methods do
    def headers_for(date)
      translated_date = I18n.l(date, format: :to_month).camelize

      header = non_operator_headers_for(date, translated_date)
      header << operator_headers_for(date, translated_date)
      header
    end

    def non_operator_headers_for(date, translated_date)
      self::NO_OPERATOR_KINDS.map do |kind|
        _scope = where(kind: kind).at_month(date).map(&:to_info)

        if _scope.count > 0
          amount = _scope.sum { |r| r[2] }

          _scope << [nil, nil, amount]
          title = I18n.t('view.movements.kind.' + kind)

          [_scope, [translated_date, title]]
        end
      end.compact
    end

    def operator_headers_for(date, translated_date)
      date_range = date.to_datetime.beginning_of_month..date.to_datetime.end_of_month
      title =  I18n.t('view.movements.operators')

      _scope = where(created_at: date_range).to_operators.where(
        kind: [:payoff, :upfront_r, :refunded]
      )

      operator_ids =
      total = 0.0

      operators = Operator.where(
        id: _scope.pluck(:to_account_id).uniq
      ).pluck(:id, :name).sort_by { |k| k.last }

      data = operators.map do |id, name|
        operator_scope = _scope.where(to_account_id: id)

        operator_amount = operator_scope.map do |o|
          if o.refunded?
            o.amount if o.versions.last&.reify&.upfront? # LEGACY
          else
            o.amount
          end
        end.compact.sum.round(2)
        total += operator_amount

        [
          nil,
          nil,
          operator_amount,
          name
        ]
      end

      data << [nil, nil, total]

      [data, [translated_date, title]]
    end

    def to_monthly_info(date)
      #require 'csv'

      table_header = %w(date bill amount provider details).map do |k|
        I18n.t('view.movements.reports.' + k)
      end
      csv = []
      #CSV.generate do |csv|
      not_revoked.headers_for(date).each do |_scope, head|
        csv << []
        csv << head
        csv << table_header
        _scope.each { |info| csv << info }
        csv << []
      end
      csv
    end
  end
end
