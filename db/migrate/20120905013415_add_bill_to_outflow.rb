class AddBillToOutflow < ActiveRecord::Migration[4.2]
  def change
    add_column :outflows, :bill, :string
  end
end
