class AddMultiUseToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :multi_use, :string, default: nil
  end
end
