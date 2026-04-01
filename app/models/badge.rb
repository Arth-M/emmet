class Badge < ApplicationRecord
  belongs_to :badge_provider
  has_many :join_event_badges
  has_many :events, through: :join_event_badges

  validates :badge_id, :issued_at, :badge_provider, presence:  { strict: true }
  validates :badge_id, uniqueness:  { strict: true }
end
