class WasteType < ApplicationRecord
  has_many :locations
  has_many :join_location_capacity_waste_types

  validates :type, presence: {strict: true}
  validates :uniqueness, presence: {strict: true}
end
