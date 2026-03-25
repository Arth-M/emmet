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

#parsing le json
filepath = Rails.root.join('recipes-en.json')
serialized_recipes = File.read(filepath)
recipes = JSON.parse(serialized_recipes)
i=0
failed=[]

recipes.each do |recipe|

  # Find or create category
  if recipe['category'].length > 0
    category = Category.find_or_create_by!(name: recipe['category'])
  else
    category = Category.find_or_create_by!(name: 'Other')
  end


  # compute total time for future filter and display if possible
  total_time = recipe['cook_time'] + recipe['prep_time']

  # regexp for image url, if no match the url is taken as is
  match_url = recipe['image'].match(/https?%3A.+$/i)
  if match_url
    image_url = URI.decode_www_form_component(match_url[0])
  else
    image_url = recipe['image']
    puts "#{i} CHECK THIS RECIPE IMAGE"
  end
  # Create recipe (skip if already exists)
  recipe_instance = Recipe.new(
    title:     recipe['title'],
    cook_time: recipe['cook_time'],
    prep_time: recipe['prep_time'],
    total_time: total_time,
    rating:    recipe['ratings'],
    author:    recipe['author'],
    image:     image_url,
    category:  category
  )

  if !recipe_instance.save
    failed << { title: recipe['title'], errors: recipe_instance.errors.full_messages }
    next
  end

  # Create ingredient and joitn table
  recipe['ingredients'].each do |ingredient_string|

    # match through regexp
    #  match group 1: quantity : number (+string with division) then 1 word /
    #  match group 2 : ingredient : what is left
    # match2 group 1 : quantity : 1 number (+string with division)
    # match2 group 2 : ingredient: what is left
    # what separates match et match2 is parenthesis () in some ingredients
    match = ingredient_string.match(/^([\d\s⅛¼⅓½⅔¾]+\w+)\s+(.+)$/)
    match = ingredient_string.match(/^([\d⅛¼⅓½⅔¾][\d\s⅛¼⅓½⅔¾]*\w+)\s+(.+)$/)
    match2 = ingredient_string.match(/^([\d]*\s*[⅛¼⅓½⅔¾]?)(.+)$/)
    if match
      quantity        = match[1].strip
      ingredient_name = match[2].strip
    elsif match2
      quantity        = match2[1].strip
      ingredient_name = match2[2].strip
    else
      quantity = 0
      ingredient_name = ingredient_string
    end

    # lowercase to avoid "Butter" and "butter" in ingredients
    ingredient = Ingredient.find_or_create_by!(name: ingredient_name.downcase)

    RecipeIngredient.create!(
      recipe:     recipe_instance,
      ingredient: ingredient,
      quantity:   quantity
    )
  end
  puts "#{i} Created: #{recipe_instance.title}"
  i+=1

end

puts "Failed recipes: #{failed.count}"
failed.each { |f| puts "#{f[:title]}: #{f[:errors]}" }
puts "Seed terminée !"
