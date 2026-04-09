require "test_helper"

class WasteTypeTest < ActiveSupport::TestCase
    test "array_waste_type retourne un Array de String" do
    result = WasteType.array_waste_type
    assert_kind_of Array, result
    result.each { |wt| assert_kind_of String, wt }
  end

  test "array_waste_type n'est pas vide" do
    assert WasteType.array_waste_type.any?, "Le seed devrait contenir des WasteType"
  end

  test "le name doit être unique" do
    existing = WasteType.first
    skip "Pas de WasteType dans le seed" unless existing

    dup = WasteType.new(name: existing.name)
    assert_raises(ActiveModel::StrictValidationFailed) { dup.validate! }
  end
end
