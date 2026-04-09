require "test_helper"

class DashboardQueriesTest < ActiveSupport::TestCase

  def setup
    @location = Location
      .joins(events: :join_event_sensors)
      .where(events: { event_type: "sensor_reading" })
      .first
    @queries = DashboardQueries.new(@location.id)
  end

  # ── filling_history ────────────────────────────────────────────────────────

  test "filling_history retourne un Array" do
    assert_kind_of Array, @queries.filling_history(30)
  end

  test "filling_history respecte la limite n" do
    assert @queries.filling_history(5).size <= 5
  end

  test "chaque entrée a occurred_at et fill_percent" do
    @queries.filling_history(30).each do |entry|
      assert entry.key?(:occurred_at),  "Clé :occurred_at manquante"
      assert entry.key?(:fill_percent), "Clé :fill_percent manquante"
    end
  end

  test "filling_history est trié du plus ancien au plus récent" do
    dates = @queries.filling_history(30).map { |e| e[:occurred_at] }
    assert_equal dates.sort, dates
  end

  # ── retrieving_incidents ───────────────────────────────────────────────────

  test "retrieving_incidents retourne un Array" do
    assert_kind_of Array, @queries.retrieving_incidents
  end

  test "chaque incident a les clés type, occurred, days_since" do
    @queries.retrieving_incidents.each do |entry|
      assert entry.key?(:type),       "Clé :type manquante"
      assert entry.key?(:occurred),   "Clé :occurred manquante"
      assert entry.key?(:days_since), "Clé :days_since manquante"
    end
  end

  test "retrieving_incidents ne retourne que des incidents non résolus" do
    @queries.retrieving_incidents.each do |entry|
      incident = Incident
        .joins(:event)
        .where(events: { location_id: @location.id, occurred_at: entry[:occurred] })
        .first
      assert_equal false, incident.resolved if incident
    end
  end
end
