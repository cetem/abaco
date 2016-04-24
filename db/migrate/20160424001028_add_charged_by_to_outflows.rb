class AddChargedByToOutflows < ActiveRecord::Migration
  def change
    add_column :outflows, :charged_by, :string
  end
end
