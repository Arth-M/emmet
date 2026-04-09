require "test_helper"

class LocationTest < ActiveSupport::TestCase
    test "with_waste_type_names retourne un Hash" do
    assert_kind_of Hash, Location.with_waste_type_names
  end

  test "with_waste_type_names associe des Integer à des String" do
    result = Location.with_waste_type_names

    result.each do |location_id, waste_type_name|
      assert_kind_of Integer, location_id
      assert_kind_of String,  waste_type_name
    end
  end

  test "une location répond aux associations attendues" do
    location = Location.first
    assert_respond_to location, :events
    assert_respond_to location, :capacities
    assert_respond_to location, :waste_types
    assert_respond_to location, :incidents
  end

  test "id_pav est unique — une valeur dupliquée lève une erreur stricte" do
    existing = Location.first
    skip "Pas de Location dans le seed" unless existing

    dup = Location.new(existing.attributes.except("id", "created_at", "updated_at"))
    assert_raises(ActiveModel::StrictValidationFailed) { dup.validate! }
  end
end
