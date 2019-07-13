class AddProviderIdToOutflows < ActiveRecord::Migration
  def change
    rename_column :outflows, :provider, :old_provider
    add_column :outflows, :provider_id, :integer, index: true

    # Only needed for migration, not for new installs
    # Outflow.where.not(old_provider: nil).find_each do |o|
    #   provider = o.old_provider.strip

    #   provider = if provider.present?
    #                I18n.transliterate(provider.downcase)
    #              end

    #   o.provider_id = provider ? Provider.find_or_create_by(name: provider).id : nil
    #   o.save
    # end

    remove_column :outflows, :old_provider
  end
end
