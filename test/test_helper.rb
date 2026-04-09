ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all
    # self.use_transactional_tests = true

    # Add more helper methods to be used by all tests here...
  end
end

module LocationFillHelper
  def locations_with_last_fill
    latest_event_ids = Event.sensor_events
                            .select(Arel.sql("DISTINCT ON (location_id) id"))
                            .order("location_id, occurred_at DESC")

    Location
      .joins(events: { join_event_sensors: :sensor })
      .left_joins(:incidents)
      .where(events: { id: latest_event_ids })
      .select("locations.id, locations.name, locations.lat, locations.lng, sensors.fill_percent, BOOL_OR(incidents.resolved = false) AS open_incident")
      .group("locations.id, sensors.fill_percent")
  end
end
