class IncidentsController < ApplicationController

  def index
    # from incidents
    # include events, incident_types, locations for having infos in memory for view
    @recent_incidents = Incident.includes(:event, :incident_type, event: :location)
      .joins(:event)
      # join on events to sort bu resolved (false then true) then by occurrred_at : firsts on top
      .order("incidents.resolved ASC, events.occurred_at DESC")
      # only the 50 first incidents
      .limit(50)
  end
end
