# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181011222535) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "outflows", force: :cascade do |t|
    t.string   "kind",             limit: 1,                                            null: false
    t.text     "comment"
    t.decimal  "amount",                       precision: 15, scale: 2, default: 0.0,   null: false
    t.integer  "user_id",                                                               null: false
    t.integer  "operator_id"
    t.integer  "lock_version",                                          default: 0,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bill",             limit: 255
    t.date     "bought_at"
    t.boolean  "with_incentive",                                        default: false
    t.string   "file",             limit: 255
    t.date     "start_shift"
    t.date     "finish_shift"
    t.integer  "shift_closure_id"
    t.string   "charged_by"
    t.integer  "provider_id"
  end

  add_index "outflows", ["bought_at"], name: "index_outflows_on_bought_at", using: :btree
  add_index "outflows", ["operator_id"], name: "index_outflows_on_operator_id", using: :btree
  add_index "outflows", ["shift_closure_id"], name: "index_outflows_on_shift_closure_id", using: :btree
  add_index "outflows", ["user_id"], name: "index_outflows_on_user_id", using: :btree

  create_table "providers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string   "title",        limit: 255,             null: false
    t.string   "var",          limit: 255,             null: false
    t.text     "value"
    t.integer  "lock_version",             default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["var"], name: "index_settings_on_var", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 255,              null: false
    t.string   "lastname",               limit: 255
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.integer  "roles_mask",                         default: 0,  null: false
    t.integer  "lock_version",                       default: 0,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["lastname"], name: "index_users_on_lastname", using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255, null: false
    t.integer  "item_id",                null: false
    t.string   "event",      limit: 255, null: false
    t.integer  "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  add_index "versions", ["whodunnit"], name: "index_versions_on_whodunnit", using: :btree

end
