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

ActiveRecord::Schema[7.1].define(version: 2026_04_03_143137) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "badge_providers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "badges", force: :cascade do |t|
    t.string "badge_id"
    t.datetime "issued_at"
    t.bigint "badge_provider_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_provider_id"], name: "index_badges_on_badge_provider_id"
  end

  create_table "capacities", force: :cascade do |t|
    t.integer "liters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "log_id"
    t.datetime "occurred_at"
    t.bigint "location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "event_type"
    t.index ["location_id", "event_type"], name: "index_events_on_location_id_and_event_type"
    t.index ["location_id"], name: "index_events_on_location_id"
    t.index ["occurred_at"], name: "index_events_on_occurred_at"
  end

  create_table "incident_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "incidents", force: :cascade do |t|
    t.boolean "resolved"
    t.datetime "resolved_at"
    t.string "note"
    t.bigint "incident_type_id", null: false
    t.bigint "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_incidents_on_event_id"
    t.index ["incident_type_id"], name: "index_incidents_on_incident_type_id"
    t.index ["resolved"], name: "index_incidents_on_resolved"
    t.index ["resolved_at"], name: "index_incidents_on_resolved_at"
  end

  create_table "join_event_badges", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "badge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "access_granted"
    t.boolean "badge_revoked"
    t.string "anomaly_flags", default: [], array: true
    t.index ["badge_id"], name: "index_join_event_badges_on_badge_id"
    t.index ["event_id"], name: "index_join_event_badges_on_event_id"
  end

  create_table "join_event_sensors", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "sensor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_join_event_sensors_on_event_id"
    t.index ["sensor_id"], name: "index_join_event_sensors_on_sensor_id"
  end

  create_table "join_location_capacity_waste_types", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.bigint "capacity_id", null: false
    t.bigint "waste_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["capacity_id"], name: "index_join_location_capacity_waste_types_on_capacity_id"
    t.index ["location_id"], name: "index_join_location_capacity_waste_types_on_location_id"
    t.index ["waste_type_id"], name: "index_join_location_capacity_waste_types_on_waste_type_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "id_pav"
    t.string "name"
    t.text "address"
    t.string "city"
    t.integer "zip"
    t.float "lat"
    t.float "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sensors", force: :cascade do |t|
    t.integer "fill_percent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "waste_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "badges", "badge_providers"
  add_foreign_key "events", "locations"
  add_foreign_key "incidents", "events"
  add_foreign_key "incidents", "incident_types"
  add_foreign_key "join_event_badges", "badges"
  add_foreign_key "join_event_badges", "events"
  add_foreign_key "join_event_sensors", "events"
  add_foreign_key "join_event_sensors", "sensors"
  add_foreign_key "join_location_capacity_waste_types", "capacities"
  add_foreign_key "join_location_capacity_waste_types", "locations"
  add_foreign_key "join_location_capacity_waste_types", "waste_types"
end
