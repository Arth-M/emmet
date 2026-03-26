class RecipesController < ApplicationController
  def top_five
    # based on recipe class method top_n
    @top_5_recipes = Recipe.top_n(5)
  end
  def show
    # find recipe by id, if not present render homepage through top_five method
    @recipe = Recipe.find_by(id: params[:id])
    if @recipe.nil?
      @top_5_recipes = Recipe.top_n(5)
      render "top_five"
    end
  end

  def found_recipes
    # analysis of user query
    # to string to avoid error in case params[:query] is nil
    # slice to avoid more than 200 length
    # split by space or -
    # one word by array entry, only letters
    # delete empty entries
    # 10 words max
    words = params[:query].to_s
          .slice(0, 200)
          .split(/[\s,\-]+/)
          .map  { |w| w.gsub(/[^\p{L}]/u, '').downcase }
          .reject(&:empty?)
          .first(10)

    if !words.empty?
      # based on search class method from recipe model, receives several lines for each recipe with ingredient name and id
      recipes_many_matches = Recipe.search(words)
      # accumulate result of each in an empty hash
      recipes_score = recipes_many_matches.each_with_object({}) do |row, hash|
        # find user word(s) matching ingredient
        matched_words = words.select { |w| row.ingredient_name.include?(w.downcase) }
        next if matched_words.empty?

        # recipe_id will be the key to group rows by recipe
        recipe_id = row.id

        # if recipe already in hash add matched words avoiding duplicates, else create new entry
        if hash[recipe_id]
          hash[recipe_id][:matched_words] |= matched_words
        else
          hash[recipe_id] = {
            recipe: row,
            matched_words: matched_words
          }
        end
      # return only the hash values (no more recipe_id key) as an array of hashes, map to add the score
      # score is number of user words found in recipe / nbr of user words
      end.values.map do |entry|
        entry[:score] = entry[:matched_words].length.to_f / words.length
        entry
      end

      if recipes_score.empty?
        # display an message to user
        render turbo_stream: turbo_stream.replace("flash-message",
          partial: "shared/flash_message",
          locals: { message: "No recipe was found with these ingredients" })
      end

      # we take the 10 recipes with the best computed score and rating
      @top_recipes = recipes_score
      .sort_by { |r| [-r[:score], -r[:recipe].rating] }
      .first(10)
      # map to select the recipe instance
      .map { |r| r[:recipe] }

      # we pull them out from the recipes variable to create a new variable with all the other recipes
      # map to select the recipe instance
      top_ids = @top_recipes.map { |r| r.id }
      @other_recipes = recipes_score.reject { |r| top_ids.include?(r[:recipe].id) }.map { |r| r[:recipe] }
    else
      # if no word in query, display message to user
      render turbo_stream: turbo_stream.replace("flash-message",
        partial: "shared/flash_message",
        locals: { message: "Please enter some ingredients" })
    end
  end
end
