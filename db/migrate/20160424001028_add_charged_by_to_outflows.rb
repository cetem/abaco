class AddChargedByToOutflows < ActiveRecord::Migration[4.2]
  def change
    add_column :outflows, :charged_by, :string
  end
end
