class AddIndexToOutflow < ActiveRecord::Migration[4.2]
  def change
    add_index :outflows, :bought_at
  end
end
