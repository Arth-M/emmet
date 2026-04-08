require "test_helper"

class IncidentsToggleFlowTest < ActionDispatch::IntegrationTest

  test "consultation liste ouverte puis résolution d'un incident" do
    get incidents_index_path
    assert_response :success
    assert_equal false, assigns(:showing_resolved)

    incident = Incident.where(resolved: false).first
    skip "Pas d'incident ouvert dans le seed" unless incident

    patch toggle_resolved_incident_path(incident)
    assert_response :redirect

    incident.reload
    assert_equal true, incident.resolved
    assert_not_nil incident.resolved_at

    # L'incident résolu apparaît bien dans la liste résolue
    get incidents_index_path(resolved: "true")
    assert_includes assigns(:incidents).map(&:id), incident.id
  end

  test "consultation liste résolue puis ré-ouverture d'un incident" do
    get incidents_index_path(resolved: "true")
    assert_response :success

    incident = Incident.where(resolved: true).first
    skip "Pas d'incident résolu dans le seed" unless incident

    patch toggle_resolved_incident_path(incident)
    assert_response :redirect

    incident.reload
    assert_equal false, incident.resolved
    assert_nil incident.resolved_at

    # L'incident ré-ouvert apparaît dans la liste ouverte
    get incidents_index_path
    assert_includes assigns(:incidents).map(&:id), incident.id
  end
end
