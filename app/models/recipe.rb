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
    # select all from recipe, ingredient id and name for analysis in recipes_controller
    # take first 100 recipes

  recipe_ids = joins(:ingredients)
    .where(
      words.map { "ingredients.name LIKE ?" }.join(" OR "),
      *words.map { |w| "%#{w}%" }
    )
    .distinct
    .limit(100)
    .pluck(:id)

  joins(:ingredients)
    .select(
      "recipes.*",
      "ingredients.id AS ingredient_id",
      "ingredients.name AS ingredient_name"
    )
    .where(id: recipe_ids)
  end


end
