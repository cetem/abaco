class ReplaceProviderAssociations < ActiveRecord::Migration[4.2]
  def change
    # Replacing association
    Provider.all.find_each do |account|
      Movement.where(
        provider_id: account.old_id
      ).update_all(
        to_account_id:   account.id,
        to_account_type: Provider.name
      )
    end
  end
end
