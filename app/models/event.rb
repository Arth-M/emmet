class Event < ApplicationRecord
  belongs_to :location

  validates :log_id, :occurred_at, presence: {strict: true}
  validates :log_id, uniqueness:  { strict: true }
end
