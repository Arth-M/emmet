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
          .map  { |w| w.gsub(/[^\p{L}]/u, '') }
          .reject(&:empty?)
          .first(10)

    puts words

    if !words.empty?
      # use search method from recipe model
      recipes = Recipe.search(words)

      if recipes.empty?
        # display an message to user
        render turbo_stream: turbo_stream.replace("flash-message",
          partial: "shared/flash_message",
          locals: { message: "No recipe was found with these ingredients" })
      end

      # we take the 10 recipes with the best ratings
      @top_recipes = recipes.sort_by(&:rating).last(10)
      # we pull them out from the recipes variable to create a new variable with all the other recipes
      top_ids = @top_recipes.map { |recipe| recipe.id }
      @other_recipes = recipes.reject { |r| top_ids.include?(r.id) }
    else
      # if no word in query, display message to user
      render turbo_stream: turbo_stream.replace("flash-message",
        partial: "shared/flash_message",
        locals: { message: "Please enter some ingredients" })
    end
  end
end
