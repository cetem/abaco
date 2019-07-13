class AddRevokedToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :revoked, :boolean, default: false
  end
end
