class BadgeProvider < ApplicationRecord
  has_many :badges

  validates :name, presence:  { strict: true }
  validates :name, uniqueness:  { strict: true }
end
