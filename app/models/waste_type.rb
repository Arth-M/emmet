class WasteType < ApplicationRecord
  has_many :join_location_capacity_waste_types

  validates :name, presence: {strict: true}
  validates :name, uniqueness: {strict: true}

  def self.array_waste_type
    pluck(:name)
  end
end
