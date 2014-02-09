class AddWithIncentiveToOutflows < ActiveRecord::Migration
  def change
    add_column :outflows, :with_incentive, :boolean, default: false
  end
end
