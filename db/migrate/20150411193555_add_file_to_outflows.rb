class AddFileToOutflows < ActiveRecord::Migration[4.2]
  def change
    add_column :outflows, :file, :string
 end
end
