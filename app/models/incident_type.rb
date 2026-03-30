class IncidentType < ApplicationRecord
has_many :incidents
has_many :events, through: :incidents

validates :type, presence:  { strict: true }
validates :type, uniqueness:  { strict: true }
end
