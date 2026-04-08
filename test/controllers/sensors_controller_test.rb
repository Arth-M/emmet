require "test_helper"

class SensorsControllerTest < ActionDispatch::IntegrationTest

  test "GET /sensors répond 200" do
    get sensors_index_path
    assert_response :success
  end

  test "GET /sensors assigne @locations_fill" do
    get sensors_index_path
    assert_not_nil assigns(:locations_fill)
  end

  test "chaque location de @locations_fill a un fill_percent" do
    get sensors_index_path
    assigns(:locations_fill).each do |location|
      assert_respond_to location, :fill_percent, "#{location.name} n'a pas de fill_percent"
    end
  end
end
