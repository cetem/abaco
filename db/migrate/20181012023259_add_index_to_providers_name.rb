class AddIndexToProvidersName < ActiveRecord::Migration[4.2]
  def change
    add_index :providers, :name
  end
end
