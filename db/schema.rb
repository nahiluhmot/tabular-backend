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

ActiveRecord::Schema.define(version: 20150415202549) do

  create_table "activity_logs", force: :cascade do |t|
    t.integer  "user_id",       limit: 4,   null: false
    t.integer  "activity_id",   limit: 4,   null: false
    t.string   "activity_type", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activity_logs", ["user_id"], name: "index_activity_logs_on_user_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "body",       limit: 65535, null: false
    t.integer  "user_id",    limit: 4,     null: false
    t.integer  "tab_id",     limit: 4,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["tab_id"], name: "index_comments_on_tab_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.integer  "followee_id", limit: 4, null: false
    t.integer  "follower_id", limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["followee_id", "follower_id"], name: "index_relationships_on_followee_id_and_follower_id", unique: true, using: :btree
  add_index "relationships", ["followee_id"], name: "index_relationships_on_followee_id", using: :btree
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "key",        limit: 255, null: false
    t.integer  "user_id",    limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["key"], name: "index_sessions_on_key", unique: true, using: :btree
  add_index "sessions", ["user_id"], name: "index_sessions_on_user_id", using: :btree

  create_table "tabs", force: :cascade do |t|
    t.text     "body",       limit: 65535, null: false
    t.string   "artist",     limit: 255,   null: false
    t.string   "album",      limit: 255,   null: false
    t.string   "title",      limit: 255,   null: false
    t.integer  "user_id",    limit: 4,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tabs", ["artist", "album", "title"], name: "index_tabs_on_artist_and_album_and_title", type: :fulltext
  add_index "tabs", ["user_id"], name: "index_tabs_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",      limit: 255,   null: false
    t.text     "password_hash", limit: 65535, null: false
    t.string   "password_salt", limit: 255,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  add_foreign_key "activity_logs", "users"
  add_foreign_key "comments", "tabs"
  add_foreign_key "comments", "users"
  add_foreign_key "relationships", "users", column: "followee_id"
  add_foreign_key "relationships", "users", column: "follower_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "tabs", "users"
end
