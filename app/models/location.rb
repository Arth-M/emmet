class Location < ApplicationRecord
  has_many :events
  has_many :join_location_capacity_waste_types
  has_many :capacities, through: :join_location_capacity_waste_types
  has_many :waste_types, through: :join_location_capacity_waste_types

  has_many :incidents, through: :events


  validates :id_pav, :name, :address, :city, :zip, :lat, :lng, presence: {strict: true}
  validates :id_pav, uniqueness: {strict: true}


  def lat_f = lat.to_f
  def lng_f = lng.to_f
end
