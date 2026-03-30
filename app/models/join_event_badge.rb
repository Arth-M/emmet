class JoinEventBadge < ApplicationRecord
  belongs_to :event
  belongs_to :badge
end
