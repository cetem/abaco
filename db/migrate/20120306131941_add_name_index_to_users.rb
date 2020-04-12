class AddNameIndexToUsers < ActiveRecord::Migration[4.2]
  def change
    add_index :users, :name
  end
end
