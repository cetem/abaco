class AddShiftClosureIdToOutflows < ActiveRecord::Migration[4.2]
  def change
    add_column :outflows, :shift_closure_id, :integer
    add_index :outflows, :shift_closure_id
  end
end
