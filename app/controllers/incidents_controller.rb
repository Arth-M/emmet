class IncidentsController < ApplicationController

  def index
    @recent_incidents = Incident.includes(:event, :incident_type, event: :location)
                                .joins(:event)
                                .order("incidents.resolved ASC, events.occurred_at DESC")
                                .limit(50)
  end
end
