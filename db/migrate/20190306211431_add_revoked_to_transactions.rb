class AddRevokedToTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :transactions, :revoked, :boolean, default: false
  end
end
