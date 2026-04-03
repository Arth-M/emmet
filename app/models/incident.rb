class Incident < ApplicationRecord
  belongs_to :incident_type
  belongs_to :event
  has_one :location, through: :event

  validates :incident_type, presence: { strict: true }
  validates :resolved, inclusion: { in: [true, false] }

  # resolution delay in hours, needs an incident and an associated event
  # to call on an incident instance
  def resolution_delay_hours
    if resolved && resolved_at && event.occurred_at
      ((resolved_at - event.occurred_at) / 3600).round(1)
    end
  end


end
