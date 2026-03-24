class Recipe < ApplicationRecord
  belongs_to :category
  has_many :recipe_ingredients
  has_many :ingredients, through: :recipe_ingredients

  validates :title, :cook_time, :prep_time, :total_time,
  :rating, presence:  { strict: true }
  validates :title, uniqueness: true
end
