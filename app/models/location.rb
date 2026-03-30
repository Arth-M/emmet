class Location < ApplicationRecord
  belongs_to :capacity
  belongs_to :waste_type
  has_many :events
  has_many :join_location_capacity_waste_types


  validates :id_pav, :name, :address, :city, :zip, :lat, :lng, presence: {strict: true}
  validates :id_pav, uniqueness: {strict: true}
end
