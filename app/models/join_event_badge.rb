class JoinEventBadge < ApplicationRecord
  belongs_to :event
  belongs_to :badge

  validates :event, :badge, presence: {strict: true}
end
