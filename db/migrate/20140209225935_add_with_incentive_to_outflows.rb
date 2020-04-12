class AddWithIncentiveToOutflows < ActiveRecord::Migration[4.2]
  def change
    add_column :outflows, :with_incentive, :boolean, default: false
  end
end
