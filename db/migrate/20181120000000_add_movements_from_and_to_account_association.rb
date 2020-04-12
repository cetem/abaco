class AddMovementsFromAndToAccountAssociation < ActiveRecord::Migration[4.2]
  def change
    add_column :movements, :from_account_id, :uuid
    add_column :movements, :from_account_type, :string
    add_column :movements, :to_account_id, :uuid
    add_column :movements, :to_account_type, :string

    add_index :movements, [:from_account_id, :from_account_type]
    add_index :movements, [:to_account_id, :to_account_type]
  end
end
