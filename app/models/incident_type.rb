class IncidentType < ApplicationRecord
has_many :incidents

validates :name, presence:  { strict: true }
validates :name, uniqueness:  { strict: true }
end
