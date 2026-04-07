class DashboardQueries
  def initialize(location)
    @location_id = location
  end

  def filling_history(n)
    JoinEventSensor
      .joins(:event, :sensor)
      # join events, sensors where location is clicked pav, and event_tyep sensor_reading
      .where(events: { location_id: @location_id, event_type: 'sensor_reading' })
      .order("events.occurred_at DESC")
      # select the last 30 events
      .limit(n)
      .pluck("events.occurred_at", "sensors.fill_percent")
      # return an array of arrays [occurred_at, fill_percent]
      # reverse array to have early occurred_at on left and latest on right
      .reverse
      # create object to pass it to json response
      .map { |occurred_at, fill_percent| { occurred_at: occurred_at, fill_percent: fill_percent } }
  end

  def retrieving_incidents
    Incident
    # join events, incident_types,
      .joins(:event, :incident_type)
      .references(:event)
      # where location is the one clicked by user (events.location_id = location.id) and incidents are not resolved
      .where(events: { location_id: @location_id })
      .where(resolved: false)
      .order("events.occurred_at DESC")
      # the latest first, then create the object to pass it to json response
      .map do |i|
        {
          type:      i.incident_type.name,
          occurred:  i.event.occurred_at,
          days_since: i.days_since_occurred
        }
      end
  end
end
