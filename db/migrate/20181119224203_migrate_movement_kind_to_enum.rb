class MigrateMovementKindToEnum < ActiveRecord::Migration[4.2]
  def change
    rename_column :movements, :kind, :old_kind
    add_column :movements, :kind, :string, index: true

    old_kind_enum = {
     'u' => :upfront,
     'f' => :to_favor,
     'r' => :refunded,
     'm' => :maintenance,
     'x' => :payoff,
     'o' => :other,
     'c' => :cetem_gral,
     'g' => :cca_gral,
     'l' => :library,
     'q' => :tops_rings,
     'p' => :paper,
     't' => :toner
    }

    Movement.distinct.pluck(:old_kind).each do |kind_value|
      old_key = old_kind_enum[kind_value]
      new_key = Movement.kinds[old_key]

      Movement.where(old_kind: kind_value).update_all(kind: new_key)
    end

    remove_column :movements, :old_kind
  end
end
