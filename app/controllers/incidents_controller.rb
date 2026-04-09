class IncidentsController < ApplicationController

  def index
    #from queries incidents_queries.rb
    # show resolved or unresolved incidents
    incident_queries = IncidentsQueries.new
    if params[:resolved] == "true"
      @incidents = incident_queries.resolved_incidents(150)
      @showing_resolved = true
    else
      @incidents = incident_queries.opened_incidents
      @showing_resolved = false
    end
  end

  # update an incident to resolved or open again
  def toggle_resolved
    incident = Incident.find(params[:id].to_i)
    incident.update!(
      resolved: !incident.resolved,
      resolved_at: incident.resolved ? nil : Time.current
    )
    redirect_back fallback_location: incidents_index_path
  end
end
