class AddRevokedToMovement < ActiveRecord::Migration
  def change
    add_column :movements, :revoked, :boolean, default: false
  end
end
