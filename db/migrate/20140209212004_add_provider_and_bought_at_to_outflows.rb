class AddProviderAndBoughtAtToOutflows < ActiveRecord::Migration[4.2]
  def change
    add_column :outflows, :provider, :string, limit: 200
    add_column :outflows, :bought_at, :date
  end
end
