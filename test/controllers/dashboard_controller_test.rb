require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest

  # ── GET / (index) ──────────────────────────────────────────────────────────

  test "GET / répond 200" do
    get root_path
    assert_response :success
  end

  test "GET / assigne @locations_for_map en JSON valide" do
    get root_path
    assert_not_nil assigns(:locations_for_map)
    assert_kind_of Array, JSON.parse(assigns(:locations_for_map))
  end

  test "GET / assigne @waste_types comme Array" do
    get root_path
    assert_kind_of Array, assigns(:waste_types)
  end

  test "GET / assigne @avg_fill" do
    get root_path
    assert_not_nil assigns(:avg_fill)
  end

  test "GET / assigne @open_incidents_count et @resolution_rate" do
    get root_path
    assert_not_nil assigns(:open_incidents_count)
    assert_not_nil assigns(:resolution_rate)
  end

  test "GET / assigne @critical_pavs et @moderate_critical_pavs comme Array" do
    get root_path
    assert_kind_of Array, assigns(:critical_pavs)
    assert_kind_of Array, assigns(:moderate_critical_pavs)
  end

  test "@critical_pavs_count et @moderate_critical_pavs_count sont >= 0" do
    get root_path
    assert assigns(:critical_pavs_count) >= 0
    assert assigns(:moderate_critical_pavs_count) >= 0
  end

  # ── GET /home/pav/:id (pav_detail) ────────────────────────────────────────

  test "pav_detail répond en JSON avec fill_history et incidents" do
    location = Location
      .joins(events: :join_event_sensors)
      .where(events: { event_type: "sensor_reading" })
      .first
    skip "Pas de location avec sensor_reading dans le seed" unless location

    get "/home/pav/#{location.id}"
    assert_response :success
    assert_equal "application/json", response.content_type.split(";").first

    body = JSON.parse(response.body)
    assert body.key?("fill_history"), "Clé fill_history manquante"
    assert body.key?("incidents"),    "Clé incidents manquante"
    assert_kind_of Array, body["fill_history"]
    assert_kind_of Array, body["incidents"]
  end

  test "pav_detail avec un id inexistant retourne fill_history et incidents vides" do
    get "/home/pav/0"
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal [], body["fill_history"]
    assert_equal [], body["incidents"]
  end
end
