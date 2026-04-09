require "test_helper"

class IncidentTest < ActiveSupport::TestCase

  def setup
    @resolved_incident   = Incident.joins(:event).where(resolved: true).first
    @unresolved_incident = Incident.joins(:event).where(resolved: false).first
  end

  # ── Validations ────────────────────────────────────────────────────────────

  test "un incident sans incident_type lève une erreur stricte" do
    assert_raises(ActiveModel::StrictValidationFailed) do
      Incident.new(resolved: false, event: Event.first).validate!
    end
  end

  test "resolved doit être true ou false, pas nil" do
    incident = Incident.new(
      resolved:      nil,
      incident_type: IncidentType.first,
      event:         Event.first
    )
    incident.validate
    assert_includes incident.errors[:resolved], "is not included in the list"
  end

  # ── #resolution_delay_days ─────────────────────────────────────────────────

  test "resolution_delay_days retourne un Integer >= 0 pour un incident résolu" do
    # skip "Pas d'incident résolu dans le seed" unless @resolved_incident
    result = @resolved_incident.resolution_delay_days
    assert_kind_of Integer, result
    assert result >= 0
  end

  test "resolution_delay_days retourne nil pour un incident non résolu" do
    # skip "Pas d'incident ouvert dans le seed" unless @unresolved_incident
    assert_nil @unresolved_incident.resolution_delay_days
  end

  # ── #days_since_occurred ───────────────────────────────────────────────────

  test "days_since_occurred retourne un Integer >= 0 pour un incident ouvert" do
    # skip "Pas d'incident ouvert dans le seed" unless @unresolved_incident
    result = @unresolved_incident.days_since_occurred
    assert_kind_of Integer, result
    assert result >= 0
  end

  test "days_since_occurred retourne nil pour un incident résolu" do
    # skip "Pas d'incident résolu dans le seed" unless @resolved_incident
    assert_nil @resolved_incident.days_since_occurred
  end

  # ── .open_incident_resolution_rate ────────────────────────────────────────

  test "open_incident_resolution_rate retourne les deux clés attendues" do
    result = Incident.open_incident_resolution_rate
    assert result.key?(:open_incidents_count)
    assert result.key?(:resolution_rate)
  end

  test "open_incidents_count est un Integer >= 0" do
    result = Incident.open_incident_resolution_rate
    assert_kind_of Integer, result[:open_incidents_count]
    assert result[:open_incidents_count] >= 0
  end

  test "resolution_rate est entre 0 et 100" do
    rate = Incident.open_incident_resolution_rate[:resolution_rate]
    assert rate >= 0 && rate <= 100, "resolution_rate invalide : #{rate}"
  end

  test "open_incidents_count correspond au COUNT réel en base" do
    expected = Incident.where(resolved: false).count
    assert_equal expected, Incident.open_incident_resolution_rate[:open_incidents_count]
  end
end
