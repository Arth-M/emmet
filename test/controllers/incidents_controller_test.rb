require "test_helper"

class IncidentsControllerTest < ActionDispatch::IntegrationTest

  # ── GET /incidents ─────────────────────────────────────────────────────────

  test "GET /incidents répond 200" do
    get incidents_index_path
    assert_response :success
  end

  test "GET /incidents sans params affiche les incidents ouverts" do
    get incidents_index_path
    assert_equal false, assigns(:showing_resolved)
    assert assigns(:incidents).all? { |i| i.resolved == false }
  end

  test "GET /incidents?resolved=true affiche les incidents résolus" do
    get incidents_index_path(resolved: "true")
    assert_equal true, assigns(:showing_resolved)
    assert assigns(:incidents).all? { |i| i.resolved == true }
  end

  # ── PATCH /incidents/:id/toggle_resolved ──────────────────────────────────

  test "toggle_resolved passe un incident ouvert à résolu" do
    incident = Incident.where(resolved: false).first

    patch toggle_resolved_incident_path(incident)
    # use_transactional_tests = true : le changement est rollbacké après le test
    assert_equal true, incident.reload.resolved
    assert_not_nil incident.resolved_at
  end

  test "toggle_resolved passe un incident résolu à ouvert" do
    incident = Incident.where(resolved: true).first

    patch toggle_resolved_incident_path(incident)
    assert_equal false, incident.reload.resolved
    assert_nil incident.resolved_at
  end

  test "toggle_resolved redirige après la modification" do
    incident = Incident.first

    patch toggle_resolved_incident_path(incident)
    assert_response :redirect
  end
end
