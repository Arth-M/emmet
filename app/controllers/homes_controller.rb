class HomesController < ApplicationController
  # see controllers => concerns => location_fill.rb module
  include LocationFill
  def index
    # --- Carte : toutes les locations avec leur dernier fill_percent ---
    # from module location_fill
    @locations_for_map = locations_with_last_fill

    # --- Sidebar : PAV critiques (fill > 85%) ---
    @critical_pavs = @locations_for_map
                       .select { |l| l.fill_percent > 85 }
                       .sort_by { |l| -l.fill_percent.to_i }
    @moderate_critical_pavs = @locations_for_map
                       .select { |l| l.fill_percent > 70 }
                       .sort_by { |l| -l.fill_percent.to_i }

    # --- KPIs globaux ---
    incidents_counts = Incident.group(:resolved).count
    @open_incidents_count = incidents_counts[false] || 0
    resolved_count   = incidents_counts[true]  || 0
    total_incidents = @open_incidents_count + resolved_count
    @resolution_rate = total_incidents.zero? ? 0 : (resolved_count.to_f / total_incidents * 100).round(1)
    fills = @locations_for_map.map(&:fill_percent)
    @avg_fill = fills.any? ? (fills.sum.to_f / fills.size).round(1) : 0
    @critical_pavs_count  = @critical_pavs.size
    @moderate_critical_pavs_count  = @moderate_critical_pavs.size


  end

  # AJAX — clic sur un PAV
  def pav_detail
    location = Location.find(params[:id])

    # Historique fill dans le temps
    fill_history = JoinEventSensor
      .joins(:event, :sensor)
      .where(events: { location_id: location.id, event_type: 'sensor_reading' })
      .limit(30)
      .order("events.occurred_at ASC")
      .pluck("events.occurred_at", "sensors.fill_percent")
      .map { |t, v| { t: t, v: v } }

    # Incidents de cette location
    pav_incidents = Incident
      .joins(:event, :incident_type)
      .includes(:event, :incident_type)
      .where(events: { location_id: location.id })
      .order("events.occurred_at DESC")
      .map do |i|
        {
          type:      i.incident_type.name,
          resolved:  i.resolved,
          delay_h:   i.resolution_delay_hours,
          occurred:  i.event.occurred_at
        }
      end

    render json: { fill_history:, incidents: pav_incidents }
  end

  private

  # def open_incident_location_ids
  #   @open_incident_location_ids ||= Incident
  #     .joins(:event)
  #     .where(resolved: false)
  #     .pluck("events.location_id")
  #     .to_set
  # end

end
