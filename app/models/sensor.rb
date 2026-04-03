class Sensor < ApplicationRecord
  has_many :join_event_sensors
  has_many :events, through: :join_event_sensors


  validates :fill_percent, presence: {strict: true}
  validates :fill_percent, uniqueness: {strict: true}
end
