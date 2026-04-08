require "test_helper"

class EventTest < ActiveSupport::TestCase

  test "sensor_events ne retourne que des event_type sensor_reading" do
    events = Event.sensor_events
    assert events.any?, "Le seed devrait contenir des sensor_reading"
    assert events.all? { |e| e.event_type == "sensor_reading" }
  end

  test "event_type invalide est refusé" do
    event = Event.new(
      log_id:      "log-invalid-001",
      occurred_at: Time.current,
      location:    Location.first,
      event_type:  "inconnu"
    )
    event.validate
    assert_includes event.errors[:event_type], "is not included in the list"
  end

  test "event_type sensor_reading est valide" do
    event = Event.new(
      log_id:      "log-valid-001",
      occurred_at: Time.current,
      location:    Location.first,
      event_type:  "sensor_reading"
    )
    event.validate
    assert_empty event.errors[:event_type]
  end

  test "log_id est obligatoire" do
    assert_raises(ActiveModel::StrictValidationFailed) do
      Event.new(occurred_at: Time.current, location: Location.first, event_type: "sensor_reading").validate!
    end
  end

  test "un event a bien une location associée" do
    event = Event.joins(:location).first
    assert_not_nil event.location
  end

end
