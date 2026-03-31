# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "json"

#parsing le json
filepath = Rails.root.join('pav_logs.json')
serialized_logs = File.read(filepath)
pav_logs = JSON.parse(serialized_logs)


pav_logs.each do |log|
  waste_type = WasteType.find_or_create_by!(name: log["pav"]["waste_type"])
  capacity = Capacities.find_or_create_by!(liters: log["pav"]["capacity_liters"])
  location = Locations.new(
    id_pav: log["pav"]["id"],
    name: log["pav"]["name"],
    address: log["pav"]["address"],
    city: log["pav"]["city"],
    zip: log["pav"]["zip"],
    lat: log["pav"]["lat"],
    lng: log["pav"]["lng"],
  )

  if !location.save
    failed << { title: location['id_pav'], type:"location", errors: location_instance.errors.full_messages }
    next
  end

  Join_location_capacity_waste_types.create!(
    location_id: location,
    capacity_id: capacity,
    waste_type_id: waste_type
  )

  event = Events.new(
    log_id: log["id"],
    occurred_at: log["occurred_at"],
    location_id: location,
    event_type: log["event_type"],
  )

  if !event.save
    failed << { title: event['log_id'], type:"event", errors: event_instance.errors.full_messages }
    next
  end

  if event['event_type'] === 'sensor_reading'
    sensor = Sensors.find_or_create_by!(fill_percent: log['payload']['fill_percent'])
    Join_event_sensors.create!(
      event_id: event,
      sensor_id: sensor
      )
  elsif event['event_type'] === 'badge_deposit'
    badge_provider = BadgeProviders.find_or_create_by!(name: log['payload']['badge_provider'])
    badge = Badge.create!(
      badge_id: log['payload']['badge_id']
      # CONTINUE HERE !!! 
    )
  end
end

puts "Failed processes: #{failed.count}"
failed.each { |f| puts "#{f[:title]} for #{f[:type]}: #{f[:errors]}" }
puts "Seed terminée !"
