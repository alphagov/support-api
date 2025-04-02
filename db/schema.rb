# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2019_01_30_105818) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "anonymous_contacts", id: :serial, force: :cascade do |t|
    t.string "type", limit: 255
    t.text "what_doing"
    t.text "what_wrong"
    t.text "details"
    t.string "source", limit: 255
    t.string "page_owner", limit: 255
    t.text "user_agent"
    t.string "referrer", limit: 2048
    t.boolean "javascript_enabled"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "personal_information_status", limit: 255
    t.string "slug", limit: 255
    t.integer "service_satisfaction_rating"
    t.text "user_specified_url"
    t.boolean "is_actionable", default: true, null: false
    t.string "reason_why_not_actionable", limit: 255
    t.string "path", limit: 2048, null: false
    t.integer "content_item_id"
    t.boolean "marked_as_spam", default: false, null: false
    t.boolean "reviewed", default: false, null: false
    t.index ["content_item_id", "created_at"], name: "index_anonymous_contacts_on_content_item_id_and_created_at"
    t.index ["created_at", "path"], name: "index_anonymous_contacts_on_created_at_and_path", order: { created_at: :desc }, opclass: { path: :varchar_pattern_ops }
    t.index ["created_at"], name: "index_anonymous_contacts_on_created_at"
    t.index ["path"], name: "index_anonymous_contacts_on_path", opclass: :varchar_pattern_ops
  end

  create_table "archived_service_feedbacks", id: :serial, force: :cascade do |t|
    t.string "type"
    t.string "slug"
    t.integer "service_satisfaction_rating"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "content_improvement_feedbacks", force: :cascade do |t|
    t.string "description", null: false
    t.boolean "reviewed", default: false, null: false
    t.boolean "marked_as_spam", default: false, null: false
    t.string "personal_information_status"
  end

  create_table "content_items", id: :serial, force: :cascade do |t|
    t.string "path", limit: 2048, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "document_type"
    t.index ["document_type"], name: "index_content_items_on_document_type"
  end

  create_table "content_items_organisations", id: false, force: :cascade do |t|
    t.integer "content_item_id"
    t.integer "organisation_id"
    t.index ["content_item_id", "organisation_id"], name: "index_content_items_organisations_unique", unique: true
    t.index ["organisation_id"], name: "index_content_items_organisations_on_organisation_id"
  end

  create_table "feedback_export_requests", id: :serial, force: :cascade do |t|
    t.string "notification_email", limit: 255
    t.string "filename", limit: 255
    t.datetime "generated_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "filters"
  end

  create_table "organisations", id: :serial, force: :cascade do |t|
    t.string "slug", limit: 255, null: false
    t.string "web_url", limit: 255, null: false
    t.string "title", limit: 255, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "acronym", limit: 255
    t.string "govuk_status", limit: 255
    t.string "content_id", limit: 255, null: false
    t.index ["content_id"], name: "index_organisations_on_content_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "uid"
    t.string "organisation_slug"
    t.string "organisation_content_id"
    t.string "permissions", default: [], array: true
    t.boolean "remotely_signed_out", default: false
    t.boolean "disabled", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end
end
