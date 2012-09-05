class AddBillToOutflow < ActiveRecord::Migration
  def change
    add_column :outflows, :bill, :string
  end
end
