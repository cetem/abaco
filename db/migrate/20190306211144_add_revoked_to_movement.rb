class AddRevokedToMovement < ActiveRecord::Migration[4.2]
  def change
    add_column :movements, :revoked, :boolean, default: false
  end
end
