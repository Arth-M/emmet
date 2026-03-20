class RecipeIngredient < ApplicationRecord
  belongs_to :Recipe
  belongs_to :Ingredient
end
