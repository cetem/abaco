class AddFileToOutflows < ActiveRecord::Migration
  def change
    add_column :outflows, :file, :string
 end
end
