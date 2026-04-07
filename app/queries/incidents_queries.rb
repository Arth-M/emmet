class IncidentsQueries

  def opened_incidents
    # from incidents
    # include events, incident_types, locations for having infos in memory for view
      Incident.includes(:event, :incident_type, event: :location)
          .joins(:event)
          # join on events to to select unresolvde
          .where(resolved: false)
          # then sort by occurrred_at : firsts on top
          .order("events.occurred_at DESC")
  end

  #same with resolved incidents, only 150 last resolved incidents
  def resolved_incidents(n)
    Incident.includes(:event, :incident_type, event: :location)
          .joins(:event)
          .where(resolved: true)
          .order("events.occurred_at DESC")
          .limit(n)
  end

end
