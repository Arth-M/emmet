module LocationFill

  def locations_with_last_fill
    # sensor_events: scope method in model event
    # select the last event id with sensor_reading for each location
    latest_event_ids = Event.sensor_events
    # select * from events where event type = sensor_reading
      # for each disctinct location keep one row of event.id
      .select(Arel.sql("DISTINCT ON (location_id) id"))
      # this one row per location will be the last event occurred
      .order("location_id, occurred_at DESC")

    # from locations
    Location
      # join events, join_event_sensors, sensors, & waste_types exclusion of location if no sensors data
      .joins(events: { join_event_sensors: :sensor })
      # join incidents if any, no exclusion if no incident
      .left_joins(:incidents)
      # only the last sensor event per location (see above)
      .where(events: { id: latest_event_ids })
      # select location infos, sensor fill, waste_type and open_incident = true if incident.resolved = false
      .select("locations.id, locations.name, locations.lat, locations.lng, sensors.fill_percent, BOOL_OR(incidents.resolved = false) AS open_incident")
      # one row per combination location.id / sensors fill : only one fill_percent per location with latest_event_ids
      .group("locations.id, sensors.fill_percent")
  end
end
