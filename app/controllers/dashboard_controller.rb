class DashboardController < ApplicationController
  # see controllers => concerns => location_fill.rb module
  include LocationFill
  def index
    # home page : key indicators, interactive map

    # ------- For Key indicators & Map : all locations with last fill_percent ----------
    # from module location_fill : find last fill_percent for all locations
    locations = locations_with_last_fill
    # from services DashboardService
    services = DashboardService.new(locations)

    # location of pav with waste type
    @locations_for_map = services.locations_with_waste.to_json
    @waste_types = WasteType.array_waste_type


    # --------- Key indicators ----------
    # PAVs to check
    # pavs_fill_above in private
    @critical_pavs = services.pavs_fill_above_threshold(locations, 85)
    @moderate_critical_pavs = services.pavs_fill_above_threshold(locations, 70, 85)
    @critical_pavs_count  = @critical_pavs.size
    @moderate_critical_pavs_count  = @moderate_critical_pavs.size

    # average fill
    @avg_fill = services.average_fill

   # incidents open, resolution rate
    data_incidents = Incident.open_incident_resolution_rate
    @open_incidents_count = data_incidents[:open_incidents_count]
    @resolution_rate= data_incidents[:resolution_rate]

  end

  def pav_detail
    # pav_detail as an api : when user clicks on a pav => calls pav_detail to
    # fetch details

    # collect the location id force integer
    location_id = params[:id].to_i

    #from queries pav_detail_queries
    pav_queries = DashboardQueries.new(location_id)

    # fill history with last n sensor measures
    pav_fill_history = pav_queries.filling_history(30)

    # retrieve open incidents
    pav_incidents = pav_queries.retrieving_incidents

    render json: { fill_history: pav_fill_history, incidents: pav_incidents }
  end

end
