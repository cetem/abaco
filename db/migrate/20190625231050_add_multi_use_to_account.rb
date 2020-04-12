class AddMultiUseToAccount < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :multi_use, :string, default: nil
  end
end
