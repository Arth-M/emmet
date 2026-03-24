class RecipesController < ApplicationController
  def top_five
    @top_5_recipes = Recipe.top_n(5)
  end
  def show
    @recipe = Recipe.find(params[:id])
  end

  def found_recipes
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

    puts words

    if !words.empty?
      # la recherche récupère title, id et rating et compte le nombre d'ingrédient qui matchent dans la recette (à retravailler)
      # on prend les 100 premières recettes
      recipes = Recipe.joins(:ingredients)
                      .select("recipes.*, COUNT(DISTINCT ingredients.id) AS matched_count")
                      .where(
                        words.map { "ingredients.name LIKE ?" }.join(" OR "),
                        *words.map { |w| "%#{w}%" }
                      )
                      .group("recipes.id")
                      .order("matched_count DESC")
                      .limit(100)
      if recipes.empty?
        redirect_to root_path, notice: "Aucune recette correspondante n'a été trouvée"
      end

    # we take the 10 recipes with the best ratings
    @top_recipes = recipes.sort_by(&:rating).last(10)
    puts @top_recipes
    # we pull them out from the recipes variable to create a new variable with all the other recipes
    top_ids = @top_recipes.map { |recipe| recipe.id }

    @other_recipes = recipes.reject { |r| top_ids.include?(r.id) }
    else
      redirect_to root_path, flash: { noIngredients: "Veuillez entrer des ingrédients" }
    end
  end
end
