class AddIndexToOutflow < ActiveRecord::Migration
  def change
    add_index :outflows, :bought_at
  end
end
