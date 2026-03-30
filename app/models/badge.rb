class Badge < ApplicationRecord
  belongs_to :badge_provider
  has_many :join_event_badges
  has_many :events, through: :join_event_badges

  validates :badge_id, :issued_at, :badge_revoked, :access_granted, :anomaly_flags, presence:  { strict: true }
end
