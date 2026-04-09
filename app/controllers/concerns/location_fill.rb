module LocationFill

  def locations_with_last_fill
    # sensor_events: scope method in model event
    # select the last event id with sensor_reading for each location
    latest_event_ids = Event.sensor_events
      .select(Arel.sql("DISTINCT ON (location_id) id"))
      .order("location_id, occurred_at DESC")

    # select location infos, sensor fill, waste_type and open_incident = true if incident.resolved = false
    # retunrs one fill_percent per location with latest_event_ids
    Location
      .joins(events: { join_event_sensors: :sensor })
      .left_joins(:incidents)
      .where(events: { id: latest_event_ids })
      .select("locations.id, locations.name, locations.lat, locations.lng, sensors.fill_percent,
      BOOL_OR(incidents.resolved = false) AS open_incident")
      .group("locations.id, sensors.fill_percent")
  end
end
