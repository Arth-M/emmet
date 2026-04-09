class Location < ApplicationRecord
  has_many :events
  has_many :join_location_capacity_waste_types
  has_many :capacities, through: :join_location_capacity_waste_types
  has_many :waste_types, through: :join_location_capacity_waste_types

  has_many :incidents, through: :events


  validates :id_pav, :name, :address, :city, :zip, :lat, :lng, presence: {strict: true}
  validates :id_pav, uniqueness: {strict: true}

  # returns a hash of location id along with waste_type
  def self.with_waste_type_names
    joins(join_location_capacity_waste_types: :waste_type)
    .pluck(:id, "waste_types.name")
    .to_h
  end
end
