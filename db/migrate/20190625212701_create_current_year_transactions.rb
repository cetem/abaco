class CreateCurrentYearTransactions < ActiveRecord::Migration
  def change
    Movement.where(bought_at: Time.now.all_year).find_each do |m|
      m.create_needed_transactions_for_migration if m.respond_to?(:create_needed_transactions_for_migration)
    end
  end
end
