class CreateOutflows < ActiveRecord::Migration[4.2]
  def change
    create_table :outflows do |t|
      t.string :kind, limit: 1, null: false
      t.text :comment
      t.decimal :amount, null: false, default: 0, precision: 15, scale: 2
      t.integer :user_id, null: false
      t.integer :operator_id
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end

    add_index :outflows, :user_id
    add_index :outflows, :operator_id
  end
end
