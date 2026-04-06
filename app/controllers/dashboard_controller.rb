class DashboardController < ApplicationController
  # see controllers => concerns => location_fill.rb module
  include LocationFill
  def index
    # index has his view at root

    # ------- For Key indicators & Map : all locations with last fill_percent ----------
    # from module location_fill
    locations = locations_with_last_fill
    # from service DashboardService
    services = DashboardService.new(locations)
    # location of pav with waste type
    @locations_for_map = services.locations_with_waste.to_json
    @waste_types = WasteType.array_waste_type


    # --------- Key indicators ----------
    # PAVs to check
    # cirtical : fill > 85% / moderate_criticzal: fill > 70 %
    # pavs_fill_above in private
    @critical_pavs          = pavs_fill_above_threshold(locations, 85)
    @moderate_critical_pavs = pavs_fill_above_threshold(locations, 70, 85)
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
    # pav_detail is an api : when user clicks on a pav => calls pav_detail to
    # fetch details of this pav

    # find the clicked location in db
    location = Location.find(params[:id].to_i)

    # fill history from Join event sensor
    fill_history = JoinEventSensor
      .joins(:event, :sensor)
      # join events, sensors where location is clicked pav, and event_tyep sensor_reading
      .where(events: { location_id: location.id, event_type: 'sensor_reading' })
      .order("events.occurred_at DESC")
      # select the last 30 events
      .limit(30)
      .pluck("events.occurred_at", "sensors.fill_percent")
      # return an array of arrays [occurred_at, fill_percent]
      # reverse array to have early occurred_at on left and latest on right
      .reverse
      # create object to pass it to json response
      .map { |occurred_at, fill_percent| { occurred_at: occurred_at, fill_percent: fill_percent } }

    # From incidents
    pav_incidents = Incident
    # join events, incident_types,
      .joins(:event, :incident_type)
      .references(:event)
      # where location is the one clicked by user (events.location_id = location.id)
      .where(events: { location_id: location.id })
      .order("events.occurred_at DESC")
      # the latest first, then create the object to pass it to json response
      .map do |i|
        {
          type:      i.incident_type.name,
          resolved:  i.resolved,
          delay_h:   i.resolution_delay_hours,
          occurred:  i.event.occurred_at
        }
      end

    render json: { fill_history: fill_history, incidents: pav_incidents }
  end

  private

  # select the locations with a fill_percetn above a threshold
  def pavs_fill_above_threshold(locations, min, max = nil)
    locations
      .select { |l| l.fill_percent > min && (max.nil? || l.fill_percent <= max) }
      .sort_by { |l| -l.fill_percent.to_i }
  end

end
