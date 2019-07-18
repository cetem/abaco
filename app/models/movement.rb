class Movement < ActiveRecord::Base
  include Movements::Callbacks
  include Movements::Reports
  include Movements::Scopes
  include Movements::Shifts
  include Movements::Transactions
  include Movements::Validations

  has_paper_trail
  mount_uploader :file, FileUploader

  MonthlyReport = 'monthly_report'

  # Constantes
  enum kind: {
    upfront:     'upfront',
    to_favor:    'to_favor',
    refunded:    'refunded',
    maintenance: 'maintenance',
    payoff:      'payoff',
    other:       'other',
    cetem_gral:  'cetem_gral',
    cca_gral:    'cca_gral',
    library:     'library',
    tops_rings:  'tops_rings',
    paper:       'paper',
    toner:       'toner',
    upfront_r:   'upfront_r',
    to_favor_r:  'to_favor_r',
    transfer:    'transfer'
  }
  OPERATOR_KINDS = [
    :upfront, :to_favor, :refunded, :payoff,
    :upfront_r, :to_favor_r
  ].freeze
  NO_OPERATOR_KINDS = kinds.except(*OPERATOR_KINDS).keys.freeze


  # Attributos no persistentes
  attr_accessor :from_account_autocomplete, :to_account_autocomplete

  # Relaciones
  belongs_to :user
  belongs_to :from_account, polymorphic: true
  belongs_to :to_account, polymorphic: true

  scope :not_revoked, -> { where(revoked: false) }

  # Instance methods
  def billeable?
    library? || tops_rings? || paper? || toner? || maintenance?
  end

  def operator_needed?
    self.kind.present? && !NO_OPERATOR_KINDS.include?(self.kind.to_s)
  end

  def refund!
    self.update(kind: (to_favor? ? :to_favor_r : :upfront_r))
  end

  def to_operator?
    to_account_type == 'Operator'
  end

  def self.credit_for_operator(operator_id)
    # Operator.find().balance
    operator_movements = Movement.for_operator(operator_id)

    (
      operator_movements.to_favor.sum(:amount) -
      operator_movements.upfront.sum(:amount)
    )
  end

  def revoke!
    update!(revoked: true)
    transactions.map(&:revoke!)
  end
end
