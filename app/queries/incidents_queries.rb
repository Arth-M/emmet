class IncidentsQueries
  #select all opened incidents
  def opened_incidents
      Incident.includes(:event, :incident_type, event: :location)
          .joins(:event)
          .where(resolved: false)
          .order("events.occurred_at DESC")
  end

  #select n last resolved incidents
  def resolved_incidents(n)
    Incident.includes(:event, :incident_type, event: :location)
          .joins(:event)
          .where(resolved: true)
          .order("events.occurred_at DESC")
          .limit(n)
  end

end
