class Incident < ApplicationRecord
  belongs_to :incident_type
  belongs_to :event

  validates :resolved, :resolved_at, :note, presence: { strict: true }
end
