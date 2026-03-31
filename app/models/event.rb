class Event < ApplicationRecord
  belongs_to :location
  has_many :join_event_sensors
  has_many :join_event_badges
  has_one :sensor, through: :join_event_sensor
  has_one :badge, through: :join_event_badge
  has_many :incidents
  has_many :incident_types, through: :incidents

  validates :log_id, :occurred_at, :event_type, presence: {strict: true}
  validates :log_id, uniqueness:  { strict: true }
  validates :event_type, inclusion: { in: %w[sensor_reading incident badge_deposit] }
end
