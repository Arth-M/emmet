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
end
