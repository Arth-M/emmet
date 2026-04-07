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

   # incidents open, resolution rate
   def self.open_incident_resolution_rate
    incidents_counts = group(:resolved).count
    open_incidents_count = incidents_counts[false] || 0
    resolved_count   = incidents_counts[true]  || 0
    total_incidents = open_incidents_count + resolved_count
    resolution_rate = total_incidents.zero? ? 0 : (resolved_count.to_f / total_incidents * 100).round(1)
    {open_incidents_count: open_incidents_count, resolution_rate: resolution_rate}
   end



end
