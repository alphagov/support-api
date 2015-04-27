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

ActiveRecord::Schema.define(version: 20150313183713) do

  create_table "anonymous_contacts", force: :cascade do |t|
    t.string   "type"
    t.text     "what_doing"
    t.text     "what_wrong"
    t.text     "details"
    t.string   "source"
    t.string   "page_owner"
    t.text     "url"
    t.text     "user_agent"
    t.string   "referrer",                    limit: 2048
    t.boolean  "javascript_enabled"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.string   "personal_information_status"
    t.string   "slug"
    t.integer  "service_satisfaction_rating"
    t.text     "user_specified_url"
    t.boolean  "is_actionable",                            default: true, null: false
    t.string   "reason_why_not_actionable"
    t.string   "path",                        limit: 2048
    t.integer  "content_item_id"
  end

  add_index "anonymous_contacts", ["path"], name: "index_anonymous_contacts_on_path", length: {"path"=>255}, using: :btree

  create_table "content_items", force: :cascade do |t|
    t.string   "path",       limit: 2048, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "content_items_organisations", id: false, force: :cascade do |t|
    t.integer "content_item_id"
    t.integer "organisation_id"
  end

  add_index "content_items_organisations", ["content_item_id"], name: "index_content_items_organisations_on_content_item_id", using: :btree
  add_index "content_items_organisations", ["organisation_id"], name: "index_content_items_organisations_on_organisation_id", using: :btree

  create_table "organisations", force: :cascade do |t|
    t.string   "slug",       null: false
    t.string   "web_url",    null: false
    t.string   "title",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
