require "test_helper"

class DashboardServiceTest < ActiveSupport::TestCase
  include LocationFillHelper

  def setup
    @locations = locations_with_last_fill
    @service = DashboardService.new(@locations)
  end

  # ── average_fill ───────────────────────────────────────────────────────────

  test "average_fill retourne un Float" do
    assert_kind_of Float, @service.average_fill
  end

  test "average_fill retourne 0 pour une collection vide" do
    assert_equal 0, DashboardService.new([]).average_fill
  end

  test "average_fill est cohérent avec le calcul manuel" do
    fills    = @locations.map(&:fill_percent)
    expected = (fills.sum.to_f / fills.size).round(1)
    assert_equal expected, @service.average_fill
  end

  # ── pavs_fill_above_threshold ──────────────────────────────────────────────

  test "pavs_fill_above_threshold(85) ne retourne que des PAV > 85%" do
    @service.pavs_fill_above_threshold(@locations, 85).each do |pav|
      assert pav.fill_percent > 85, "#{pav.name} : fill=#{pav.fill_percent}"
    end
  end

  test "pavs_fill_above_threshold(70, 85) retourne des PAV entre 70 et 85%" do
    @service.pavs_fill_above_threshold(@locations, 70, 85).each do |pav|
      assert pav.fill_percent > 70 && pav.fill_percent <= 85,
        "#{pav.name} hors fourchette : fill=#{pav.fill_percent}"
    end
  end

  test "pavs_fill_above_threshold est trié par fill_percent décroissant" do
    fills = @service.pavs_fill_above_threshold(@locations, 0).map(&:fill_percent)
    assert_equal fills.sort.reverse, fills
  end

  # ── locations_with_waste ───────────────────────────────────────────────────

  test "locations_with_waste retourne un Array" do
    assert_kind_of Array, @service.locations_with_waste
  end

  test "chaque élément de locations_with_waste a une clé waste_type" do
    @service.locations_with_waste.each do |loc|
      has_key = loc.key?("waste_type") || loc.key?(:waste_type)
      assert has_key, "Clé waste_type manquante pour #{loc['name']}"
    end
  end
end
