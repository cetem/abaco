class MigrateProviderToAccount < ActiveRecord::Migration[4.2]
  def change
    enable_extension 'pgcrypto'

    rename_table :providers, :accounts
    add_column :accounts, :type, :string, index: true

    Account.all.update_all(type: Provider.name)

    # Add UUID primary key
    execute 'ALTER TABLE accounts DROP CONSTRAINT accounts_pkey;'
    change_column :accounts, :id, :bigint, default: nil, null: true
    rename_column :accounts, :id, :old_id
    add_column :accounts, :id, :uuid, primary_key: true, default: 'gen_random_uuid()', null: false
  end
end
