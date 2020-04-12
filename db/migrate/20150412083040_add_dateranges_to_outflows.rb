class AddDaterangesToOutflows < ActiveRecord::Migration[4.2]
  def change
    add_column :outflows, :start_shift, :date
    add_column :outflows, :finish_shift, :date
  end
end
