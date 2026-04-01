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

i=0
failed=[]

pav_logs.each do |log|
  waste_type = WasteType.find_or_create_by!(name: log["pav"]["waste_type"])
  capacity = Capacity.find_or_create_by!(liters: log["pav"]["capacity_liters"])
  location = Location.find_or_create_by!(
    id_pav: log["pav"]["id"],
    name: log["pav"]["name"],
    address: log["pav"]["address"],
    city: log["pav"]["city"],
    zip: log["pav"]["zip"],
    lat: log["pav"]["lat"],
    lng: log["pav"]["lng"],
  )

  JoinLocationCapacityWasteType.find_or_create_by!(
    location: location,
    capacity: capacity,
    waste_type: waste_type
  )

  event = Event.new(
    log_id: log["id"],
    occurred_at: log["occurred_at"],
    location: location,
    event_type: log["event_type"],
  )

  if !event.save
    failed << { title: event['log_id'], type:"event", errors: event_instance.errors.full_messages }
    next
  end

  if event['event_type'] === 'sensor_reading'
    sensor = Sensor.find_or_create_by!(fill_percent: log['payload']['fill_percent'])
    JoinEventSensor.create!(
      event: event,
      sensor: sensor
      )
  elsif event['event_type'] === 'badge_deposit'
    badge_provider = BadgeProvider.find_or_create_by!(name: log['payload']['badge_provider'])
    issued_at = log['payload']['badge_issued_at'].to_datetime.utc
    badge = Badge.find_or_create_by!(
      badge_id: log['payload']['badge_id'],
      issued_at: issued_at,
      badge_provider: badge_provider
      )
    JoinEventBadge.create!(
      event: event,
      badge: badge,
      access_granted: log['payload']['access_granted'],
      badge_revoked: log['payload']['badge_revoked'],
      anomaly_flags: log['payload']['anomaly_flags']
      )
  elsif event['event_type'] === 'incident'
    incident_type = IncidentType.find_or_create_by!(name: log['payload']['incident_type'])

    Incident.create!(
      resolved: log['payload']['resolved'],
      resolved_at: log['payload']['resolved_at'],
      note: log['payload']['note'],
      incident_type: incident_type,
      event: event
    )
  end

  puts "Created instance #{i} #{event.log_id}"
  i += 1
end

if failed.length > 0
  puts "Failed processes: #{failed.count}"
  failed.each { |f| puts "#{f[:title]} for #{f[:type]}: #{f[:errors]}" }
end
puts "Seed terminée !"
