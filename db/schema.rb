# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_06_25_231050) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "old_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.string "multi_use"
    t.index ["name"], name: "index_accounts_on_name"
  end

  create_table "movements", id: :serial, force: :cascade do |t|
    t.text "comment"
    t.decimal "amount", precision: 15, scale: 2, default: "0.0", null: false
    t.integer "user_id", null: false
    t.integer "operator_id"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "bill"
    t.date "bought_at"
    t.boolean "with_incentive", default: false
    t.string "file"
    t.date "start_shift"
    t.date "finish_shift"
    t.integer "shift_closure_id"
    t.string "charged_by"
    t.integer "provider_id"
    t.string "kind"
    t.uuid "from_account_id"
    t.string "from_account_type"
    t.uuid "to_account_id"
    t.string "to_account_type"
    t.boolean "revoked", default: false
    t.index ["bought_at"], name: "index_movements_on_bought_at"
    t.index ["from_account_id", "from_account_type"], name: "index_movements_on_from_account_id_and_from_account_type"
    t.index ["operator_id"], name: "index_movements_on_operator_id"
    t.index ["shift_closure_id"], name: "index_movements_on_shift_closure_id"
    t.index ["to_account_id", "to_account_type"], name: "index_movements_on_to_account_id_and_to_account_type"
    t.index ["user_id"], name: "index_movements_on_user_id"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.string "var", null: false
    t.text "value"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["var"], name: "index_settings_on_var", unique: true
  end

  create_table "transactions", id: :serial, force: :cascade do |t|
    t.bigint "movement_id"
    t.uuid "account_id"
    t.decimal "amount", precision: 15, scale: 2
    t.integer "kind", limit: 2, default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "revoked", default: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["movement_id"], name: "index_transactions_on_movement_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "lastname"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "roles_mask", default: 0, null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["lastname"], name: "index_users_on_lastname"
    t.index ["name"], name: "index_users_on_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.integer "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["whodunnit"], name: "index_versions_on_whodunnit"
  end

end
