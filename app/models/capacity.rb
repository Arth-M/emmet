class Capacity < ApplicationRecord
  has_many :locations
  has_many :join_location_capacity_waste_types

  validates :liters, presence: { strict: true }
  validates :uniqueness, presence: { strict: true }
end
