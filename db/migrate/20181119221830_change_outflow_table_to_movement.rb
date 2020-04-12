class ChangeOutflowTableToMovement < ActiveRecord::Migration[4.2]
  def change
    rename_table :outflows, :movements
  end
end
