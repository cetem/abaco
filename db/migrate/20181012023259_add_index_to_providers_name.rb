class AddIndexToProvidersName < ActiveRecord::Migration
  def change
    add_index :providers, :name
  end
end
