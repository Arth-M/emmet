class JoinEventSensor < ApplicationRecord
  belongs_to :event
  belongs_to :sensor

  validates :event, :sensor, presence: {strict: true}
end
