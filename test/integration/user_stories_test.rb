class UserStoriesTest < ActionDispatch::IntegrationTest

  test "user visits homepage and sees top 5 recipes" do
    get root_path
    assert_response :success
    assert_select ".recipe-card", 5  # 5 recipe cards
  end

  test "user searches for ingredients and sees results" do
    get found_recipes_path, params: { query: "cheese egg" }
    assert_response :success
    assert_select ".recipe-card"  # at least one result
  end

  test "user clicks on a recipe and sees its detail page" do
    recipe = Recipe.first
    get recipe_path(recipe.id)
    assert_response :success
    assert_select ".recipe-card"  # the recipe card
    assert_select "#title", recipe.title  # title recipe should match
  end

  test "user searches with unknown ingredients and sees flash message" do
    get found_recipes_path, params: { query: "unknown" }
    assert_response :success
    assert_select "#flash-message", text: /No recipe was found with these ingredients/
  end
  test "user searches with no ingredients and sees flash message" do
    get found_recipes_path, params: { query: "" }
    assert_response :success
    assert_select "#flash-message", text: /Please enter some ingredients/
  end

end
