require "test_helper"

class SensorsFlowTest < ActionDispatch::IntegrationTest

  test "page sensors : toutes les locations ont un fill_percent entre 0 et 100" do
    get sensors_index_path
    assert_response :success

    locations = assigns(:locations_fill)
    assert locations.any?, "La liste de remplissage ne devrait pas être vide"

    locations.each do |loc|
      assert_not_nil loc.fill_percent
      assert loc.fill_percent.between?(0, 100),
        "#{loc.name} a un fill_percent invalide : #{loc.fill_percent}"
    end
  end

  test "navigation dashboard → sensors fonctionne" do
    get root_path
    assert_response :success

    get sensors_index_path
    assert_response :success
  end
end
