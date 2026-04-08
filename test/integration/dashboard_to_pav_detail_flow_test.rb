require "test_helper"


class DashboardToPavDetailFlowTest < ActionDispatch::IntegrationTest

  test "dashboard charge puis on peut fetcher un PAV depuis locations_for_map" do
    get root_path
    assert_response :success

    locations = JSON.parse(assigns(:locations_for_map))
    skip "Pas de locations dans le seed" if locations.empty?

    pav_id = locations.first["id"]

    get "/home/pav/#{pav_id}", headers: { "Accept" => "application/json" }
    assert_response :success

    body = JSON.parse(response.body)
    assert body.key?("fill_history")
    assert body.key?("incidents")
  end

  test "les PAV critiques ont bien fill_percent > 85" do
    get root_path
    assigns(:critical_pavs).each do |pav|
      assert pav.fill_percent > 85,
        "#{pav.name} est dans critical_pavs avec fill=#{pav.fill_percent}"
    end
  end

  test "les PAV modérément critiques ont fill_percent entre 70 et 85" do
    get root_path
    assigns(:moderate_critical_pavs).each do |pav|
      assert pav.fill_percent > 70 && pav.fill_percent <= 85,
        "#{pav.name} hors fourchette avec fill=#{pav.fill_percent}"
    end
  end

  test "le compteur sidebar = critical_count + moderate_count" do
    get root_path
    expected = assigns(:critical_pavs).size + assigns(:moderate_critical_pavs).size
    assert_equal expected, assigns(:critical_pavs_count) + assigns(:moderate_critical_pavs_count)
  end
end
