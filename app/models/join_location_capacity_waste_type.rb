class JoinLocationCapacityWasteType < ApplicationRecord
  belongs_to :location
  belongs_to :capacity
  belongs_to :waste_type

  validates :location, :capacity, :waste_type, presence: {strict: true}
end
