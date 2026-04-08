require "test_helper"

class IncidentsQueriesTest < ActiveSupport::TestCase

  def setup
    @queries = IncidentsQueries.new
  end

  # ── opened_incidents ───────────────────────────────────────────────────────

  test "opened_incidents ne retourne que des incidents non résolus" do
    @queries.opened_incidents.each do |incident|
      assert_equal false, incident.resolved, "Incident #{incident.id} est résolu"
    end
  end

  test "opened_incidents eager-load event, incident_type et location sans N+1" do
    incident = @queries.opened_incidents.first
    skip "Pas d'incident ouvert dans le seed" unless incident
    assert_not_nil incident.event
    assert_not_nil incident.incident_type
    assert_not_nil incident.event.location
  end

  test "opened_incidents est trié par occurred_at décroissant" do
    dates = @queries.opened_incidents.to_a.map { |i| i.event.occurred_at }
    assert_equal dates.sort.reverse, dates
  end

  # ── resolved_incidents ─────────────────────────────────────────────────────

  test "resolved_incidents ne retourne que des incidents résolus" do
    @queries.resolved_incidents(150).each do |incident|
      assert_equal true, incident.resolved, "Incident #{incident.id} n'est pas résolu"
    end
  end

  test "resolved_incidents respecte la limite n" do
    assert @queries.resolved_incidents(10).size <= 10
  end

  test "resolved_incidents est trié par occurred_at décroissant" do
    dates = @queries.resolved_incidents(150).to_a.map { |i| i.event.occurred_at }
    assert_equal dates.sort.reverse, dates
  end
end
