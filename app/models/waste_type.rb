class WasteType < ApplicationRecord
  has_many :join_location_capacity_waste_types

  validates :name, presence: {strict: true}
  validates :name, uniqueness: {strict: true}

  # returns an array of waste_type names
  def self.array_waste_type
    pluck(:name)
  end
end
