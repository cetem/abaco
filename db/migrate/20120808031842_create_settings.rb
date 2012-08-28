class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :title, null: false
      t.string :var, null: false
      t.text :value
      t.integer :lock_version, default: 0

      t.timestamps
    end

    add_index :settings, :var, unique: true
  end
end
