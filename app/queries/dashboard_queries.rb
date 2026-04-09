class DashboardQueries
  def initialize(location)
    @location_id = location
  end

  def filling_history(n)
    # returns array of hashes { occurred_at: occurred_at, fill_percent: fill_percent }
    # with early occurred_at on left and latest on right
    # for api query
    JoinEventSensor
      .joins(:event, :sensor)
      .where(events: { location_id: @location_id, event_type: 'sensor_reading' })
      .order("events.occurred_at DESC")
      .limit(n)
      .pluck("events.occurred_at", "sensors.fill_percent")
      .reverse
      .map { |occurred_at, fill_percent| { occurred_at: occurred_at, fill_percent: fill_percent } }
  end

  def retrieving_incidents
    # returns array of hashes {type:incident name, occurred: occurred_at, days_since: days_since_occurred}
    # for api query
    Incident
      .joins(:event, :incident_type)
      .references(:event)
      .where(events: { location_id: @location_id })
      .where(resolved: false)
      .order("events.occurred_at DESC")
      .map do |i|
        {
          type:      i.incident_type.name,
          occurred:  i.event.occurred_at,
          days_since: i.days_since_occurred
        }
      end
  end
end
