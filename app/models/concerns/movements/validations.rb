module Movements::Validations
  extend ActiveSupport::Concern

  included do
    validates :amount, :kind, :user_id, presence: true
    validates :amount, numericality: { allow_nil: true, allow_blank: true, greater_than: 0.00 }, unless: :payoff?
    validates :amount, numericality: { allow_nil: true, allow_blank: true }, if: :payoff? # esto no tiene sentido
    validates :comment, presence: true, if: :other?
    validates :bill, presence: true, if: :billeable?

    validate :validate_autocompletes
    validate :at_least_one_account_needed
  end

  def at_least_one_account_needed
    return if to_account || from_account
    errors.add(:base, :at_least_one_account_needed)
  end

  def validate_autocompletes
    if bill.present? || billeable?
      bill_error = false

      if to_account_type != 'Provider'
        errors.add(:to_account_type, :invalid)
        bill_error = true
      end

      if to_account_id.blank?
        errors.add(:to_account_autocomplete, :blank)
        bill_error = true
      end

      if bill_error
        errors.add(:base, :provider_needed_for_bill)
      end
    end

    if operator_needed?
      operator_error = false

      if to_account_type != 'Operator'
        errors.add(:to_account_type, :invalid)
        operator_error = true
      end

      if to_account_id.blank?
        errors.add(:to_account_autocomplete, :blank)
        operator_error = true
      end

      if operator_error
        errors.add(:base, :operator_needed)
      end
    end
  end
end
