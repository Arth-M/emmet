class Sensor < ApplicationRecord
  has_many :join_event_sensor

  validates :fill_percent, presence: {strict: true}
  validates :fill_percent, uniqueness: {strict: true}
end
