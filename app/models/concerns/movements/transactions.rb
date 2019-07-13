module Movements::Transactions
  extend ActiveSupport::Concern

  included do
    has_many :transactions

    after_create :create_needed_transactions
    before_update :update_transactions_amount, if: :amount_changed?
  end

  def create_needed_transactions
    if to_account
      transactions.create!(
        amount:  amount,
        account: to_account,
        kind:    operator_debit? ? :debit : :credit
      )
    end

    if from_account
      transactions.create!(
        amount:  amount,
        account: from_account,
        kind:    :debit
      )
    end
  end

  def update_transactions_amount
    transactions.all? { |t| t.update(amount: amount) }
  end

  def operator_debit?
    to_operator? && (upfront? || payoff?)
  end

  def create_needed_transactions_for_migration
    date = self.bought_at
    date = self.created_at if date == self.created_at.to_date

    if to_account
      transactions.create!(
        amount:  amount,
        account: to_account,
        kind:    operator_debit? ? :debit : :credit,
        created_at: date,
        updated_at: date
      )
    end

    if from_account
      transactions.create!(
        amount:  amount,
        account: from_account,
        kind:    :debit,
        created_at: date,
        updated_at: date
      )
    end
  end
end
