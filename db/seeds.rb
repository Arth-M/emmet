# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "json"

#parser le json
filepath = Rails.root.join('recipes-en.json')
serialized_recipes = File.read(filepath)
recipes = JSON.parse(serialized_recipes)

recipes.each do |recipe|

  # 1. Créer ou trouver la catégorie
  category = Category.find_or_create_by!(name: recipe['category'])

  # 2. Créer la recette (skip si elle existe déjà)
  recipe_instance = Recipe.new(
    title:     recipe['title'],
    cook_time: recipe['cook_time'],
    prep_time: recipe['prep_time'],
    rating:    recipe['ratings'],
    author:    recipe['author'],
    image:     recipe['image'],
    category:  category
  )

  if !recipe_instance.save
    puts "Skipping duplicate recipe: #{recipe['title']}"
    next
  end

  # 3 & 4. Créer les ingrédients et les jointures
  recipe['ingredients'].each do |ingredient_string|
    # Regexp : on capture la quantité (tout avant l'ingrédient)
    # et l'ingrédient (ce qui suit cup/cups/tablespoon/teaspoon/ounce/etc.)
    # changer : groupe 1 nombre(s) puis mots / groupe 2 : le reste
    match = ingredient_string.match(
      /^(.*?(?:cups?|tablespoons?|teaspoons?|ounces?|pounds?|grams?|kg|ml|l|pinch(?:es)?|slices?|cloves?|cans?|packages?|sticks?|\d+))\s+(.+)$/i
    )

    if match
      quantity        = match[1].strip
      ingredient_name = match[2].strip
    else
      # Pas d'unité trouvée : toute la string est l'ingrédient, quantité vide
      quantity        = nil
      ingredient_name = ingredient_string.strip
    end

    # Normalisation : lowercase pour éviter les doublons "Butter" / "butter"
    ingredient = Ingredient.find_or_create_by!(name: ingredient_name.downcase)

    RecipeIngredient.create!(
      recipe:     recipe_instance,
      ingredient: ingredient,
      quantity:   quantity
    )
  end

  puts "Created: #{recipe.title}"
end

puts "Seed terminée !"
