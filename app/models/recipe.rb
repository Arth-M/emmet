class Recipe < ApplicationRecord
  belongs_to :category
  has_many :recipe_ingredients
  has_many :ingredients, through: :recipe_ingredients

  validates :title, :cook_time, :prep_time, :total_time,
  :rating, presence:  { strict: true }
  validates :title, uniqueness: true

  # class method to select top(n) recipe - for main page - in recipes_controller
  scope :top_n, ->(n) { order(rating: :desc).limit(n) }

  def self.search(words)
    # words are ingredients - see recipes_controller
    # select all from recipe and count the number of matching ingredients
    # take first 100
    joins(:ingredients)
      .select("recipes.*, COUNT(DISTINCT ingredients.id) AS matched_count")
      .where(
        words.map { "ingredients.name LIKE ?" }.join(" OR "),
        *words.map { |w| "%#{w}%" }
      )
      .group("recipes.id")
      .order("matched_count DESC")
      .limit(100)
  end


end
