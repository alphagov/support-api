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

ActiveRecord::Schema.define(version: 20150430133750) do

  create_table "anonymous_contacts", force: :cascade do |t|
    t.string   "type",                        limit: 255
    t.text     "what_doing",                  limit: 65535
    t.text     "what_wrong",                  limit: 65535
    t.text     "details",                     limit: 65535
    t.string   "source",                      limit: 255
    t.string   "page_owner",                  limit: 255
    t.text     "url",                         limit: 65535
    t.text     "user_agent",                  limit: 65535
    t.string   "referrer",                    limit: 2048
    t.boolean  "javascript_enabled",          limit: 1
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.string   "personal_information_status", limit: 255
    t.string   "slug",                        limit: 255
    t.integer  "service_satisfaction_rating", limit: 4
    t.text     "user_specified_url",          limit: 65535
    t.boolean  "is_actionable",               limit: 1,     default: true, null: false
    t.string   "reason_why_not_actionable",   limit: 255
    t.string   "path",                        limit: 2048
    t.integer  "content_item_id",             limit: 4
  end

  add_index "anonymous_contacts", ["path"], name: "index_anonymous_contacts_on_path", length: {"path"=>255}, using: :btree

  create_table "content_items", force: :cascade do |t|
    t.string   "path",       limit: 2048, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "content_items_organisations", id: false, force: :cascade do |t|
    t.integer "content_item_id", limit: 4
    t.integer "organisation_id", limit: 4
  end

  add_index "content_items_organisations", ["content_item_id"], name: "index_content_items_organisations_on_content_item_id", using: :btree
  add_index "content_items_organisations", ["organisation_id"], name: "index_content_items_organisations_on_organisation_id", using: :btree

  create_table "organisations", force: :cascade do |t|
    t.string   "slug",       limit: 255, null: false
    t.string   "web_url",    limit: 255, null: false
    t.string   "title",      limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

end
