class JoinEventSensor < ApplicationRecord
  belongs_to :event
  belongs_to :sensor
end
