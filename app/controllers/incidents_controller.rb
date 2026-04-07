class IncidentsController < ApplicationController

  def index
    #from queries => incidents_queries.rb
    incident_queries = IncidentsQueries.new
    @opened_incidents = incident_queries.opened_incidents

    # ----------- IF TIME :  make dynamic view with another stimulus controller? or turboframe? to check
    # also the resolved incidetns (last 150 here ) --------------------------
    @resolved_incidents = incident_queries.resolved_incidents(150)
  end
end
