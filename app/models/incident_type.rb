class IncidentType < ApplicationRecord
has_many :incidents

validates :type, presence:  { strict: true }
validates :type, uniqueness:  { strict: true }
end
