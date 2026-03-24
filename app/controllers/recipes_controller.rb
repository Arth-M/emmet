class RecipesController < ApplicationController
  def top_five
    @recipes = Recipe.top_n(5)
  end
  def show
    @recipe = Recipe.find(params[:id])
  end

  def search_page

  end

  def data_search
    # on traite la query user:
    # tranforme en string pour éviter erreur si params nil
    # slice pour supprimer ce qui dépasse 200 en length
    # split pour séparer les mots si espace ou -
    # 1 mot par entrée dans l'array, lettres seulement
    # rejette les entrée vides qui ressortent des traitements précédents
    # ne garde que 10 mots max
    words = params[:query].to_s
          .slice(0, 200)
          .split(/[\s,\-]+/)
          .map  { |w| w.gsub(/[^\p{L}]/u, '') }
          .reject(&:empty?)
          .first(10)

    if words.empty?
      @recipes = Recipe.none
    else
      recipes = Recipe.joins(:ingredients)
                      .select("recipes.id, recipes.rating")
                      .where(
                        words.map { "ingredients.name LIKE ?" }.join(" OR "),
                        *words.map { |w| "%#{w}%" }
                      )
    end


    redirect_to found_recipes_path(query: recipes)
  end

  def found_recipes
    @test=params[:query]
    puts @test
  end
end
