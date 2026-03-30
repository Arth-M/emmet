class JoinLocationCapacityWasteType < ApplicationRecord
  belongs_to :location
  belongs_to :capacity
  belongs_to :waste_type
end
