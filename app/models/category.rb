class Category < ApplicationRecord
  has_many :recipes

  validates :name, presence:  { strict: true }
  validates :name, uniqueness:  { strict: true }
end
