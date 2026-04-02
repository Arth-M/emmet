module LocationFill

  def locations_with_last_fill
  # Sous-requête : dernier event sensor par location
    latest_event_ids = Event
      .where(event_type: "sensor_reading")
      .select(Arel.sql("DISTINCT ON (location_id) id"))
      .order("location_id, occurred_at DESC")

    Location
      .joins(events: { join_event_sensors: :sensor })
      .left_joins(:incidents)
      .where(events: { id: latest_event_ids })
      .select("locations.id, locations.name, locations.lat, locations.lng, sensors.fill_percent, BOOL_OR(incidents.resolved = false) AS open_incident")
      .group("locations.id, sensors.fill_percent")
  end
end
