class HomesController < ApplicationController
  def index
    # --- KPIs globaux ---
    @open_incidents_count = Incident.where(resolved: false).count
    @resolution_rate      = compute_resolution_rate
    @avg_fill             = Sensor.average(:fill_percent)&.round(1) || 0
    @critical_pavs_count  = critical_pav_ids.size

    # --- Carte : toutes les locations avec leur dernier fill_percent ---
    @locations_for_map = locations_with_last_fill

    # --- Sidebar : PAV critiques (fill > 85%) ---
    @critical_pavs = @locations_for_map
                       .select { |l| l[:fill_percent].to_i > 85 }
                       .sort_by { |l| -l[:fill_percent].to_i }

    # --- Panel bas droite : incidents récents ---
    @recent_incidents = Incident.includes(:event, :incident_type, event: :location)
                                .order("events.occurred_at DESC")
                                .joins(:event)
                                .limit(50)
  end

  # AJAX — clic sur un PAV
  def pav_detail
    location = Location.find(params[:id])

    # Historique fill dans le temps
    fill_history = JoinEventSensor
      .joins(:event, :sensor)
      .where(events: { location_id: location.id, event_type: 'sensor' })
      .order("events.occurred_at ASC")
      .pluck("events.occurred_at", "sensors.fill_percent")
      .map { |t, v| { t: parse_time(t), v: v } }

    # Incidents de cette location
    pav_incidents = Incident
      .joins(:event, :incident_type)
      .where(events: { location_id: location.id })
      .order("events.occurred_at DESC")
      .map do |i|
        {
          type:      i.incident_type.name,
          resolved:  i.resolved,
          delay_h:   i.resolution_delay_hours,
          occurred:  parse_time(i.event.occurred_at)
        }
      end

    render json: { fill_history:, incidents: pav_incidents }
  end

  private

  def locations_with_last_fill
    # Dernière valeur de fill par location via le sensor le plus récent
    sql = <<~SQL
      SELECT DISTINCT ON (locations.id)
        locations.id,
        locations.name,
        locations.lat,
        locations.lng,
        sensors.fill_percent
      FROM locations
      INNER JOIN events        ON events.location_id = locations.id
        AND events.event_type = 'sensor'
      INNER JOIN join_event_sensors ON join_event_sensors.event_id = events.id
      INNER JOIN sensors       ON sensors.id = join_event_sensors.sensor_id
      ORDER BY locations.id, events.occurred_at DESC
    SQL

    ActiveRecord::Base.connection.execute(sql).map do |row|
      {
        id:           row['id'],
        name:         row['name'],
        lat:          row['lat'].to_f,
        lng:          row['lng'].to_f,
        fill_percent: row['fill_percent'].to_i,
        open_incident: open_incident_location_ids.include?(row['id'])
      }
    end
  end

  def open_incident_location_ids
    @open_incident_location_ids ||= Incident
      .joins(:event)
      .where(resolved: false)
      .pluck("events.location_id")
      .to_set
  end

  def critical_pav_ids
    @critical_pavs_for_map&.select { |l| l[:fill_percent] > 85 }&.map { |l| l[:id] } || []
  end

  def compute_resolution_rate
    total    = Incident.count
    resolved = Incident.where(resolved: true).count
    return 0.0 if total.zero?
    (resolved.to_f / total * 100).round(1)
  end

  def parse_time(str)
    Time.zone.parse(str.to_s)&.iso8601
  rescue
    nil
  end

end
