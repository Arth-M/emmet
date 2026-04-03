class Capacity < ApplicationRecord
  has_many :join_location_capacity_waste_types

  validates :liters, presence: { strict: true }
  validates :liters, uniqueness: { strict: true }
end
