class IncidentsController < ApplicationController

  def index
    #from queries => incidents_queries.rb
    incident_queries = IncidentsQueries.new
    if params[:resolved] == "true"
      @incidents = incident_queries.resolved_incidents(150)
      @showing_resolved = true
    else
      @incidents = incident_queries.opened_incidents
      @showing_resolved = false
    end
  end

  # marquer un incident comme résolu ou le réouvrir
  def toggle_resolved
    incident = Incident.find(params[:id].to_i)
    incident.update!(
      resolved: !incident.resolved,
      resolved_at: incident.resolved ? nil : Time.current
    )
    redirect_back fallback_location: incidents_index_path
  end
end
