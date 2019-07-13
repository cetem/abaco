class ChangeOutflowTableToMovement < ActiveRecord::Migration
  def change
    rename_table :outflows, :movements
  end
end
