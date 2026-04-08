require "test_helper"

class SensorTest < ActiveSupport::TestCase
  test "fill_percent est obligatoire" do
    assert_raises(ActiveModel::StrictValidationFailed) { Sensor.new.validate! }
  end

  test "fill_percent doit être unique" do
    existing = Sensor.first
    skip "Pas de Sensor dans le seed" unless existing

    dup = Sensor.new(fill_percent: existing.fill_percent)
    assert_raises(ActiveModel::StrictValidationFailed) { dup.validate! }
  end

  test "un sensor répond à l'association events" do
    assert_respond_to Sensor.first, :events
  end
end
