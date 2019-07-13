class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.bigint :movement_id, index: true, foreign_key: true
      t.uuid :account_id, index: true, foreign_key: true
      t.decimal :amount, precision: 15, scale: 2
      t.integer :kind, limit: 1, default: ::Transaction.kinds[:credit]

      t.timestamps null: false
    end
  end
end
