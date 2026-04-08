# app/services/dashboard_service.rb
class DashboardService
  def initialize(locations)
    @locations = locations
  end

  def average_fill
    fills = @locations.map {|location| location.fill_percent}
    fills.any? ? (fills.sum.to_f / fills.size).round(1) : 0
  end

  def locations_with_waste
    # from model location
    waste_types_by_location = Location.with_waste_type_names
    @locations.map do |location|
      location.as_json.merge(waste_type: waste_types_by_location[location.id])
    end
  end

  # select the locations with a fill_percetn above a threshold
  def pavs_fill_above_threshold(locations, min, max = nil)
    @locations
      .select { |l| l.fill_percent > min && (max.nil? || l.fill_percent <= max) }
      .sort_by { |l| -l.fill_percent.to_i }
  end

end
