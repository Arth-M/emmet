require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  # simulate a request
  # check response code
  # check state of variables in controller

  test "top_five returns 200 and assigns top 5 recipes" do
    get root_path
    assert_response :success
    assert_equal 5, assigns(:top_5_recipes).length
  end

  test "show returns 200 for existing recipe and assign recipe with the good id" do
    recipe = Recipe.first
    get recipe_path(recipe.id)
    assert_response :success
    assert_equal recipe.id, assigns(:recipe).id
  end

  test "show renders top_five for unknown recipe" do
    get recipe_path(0)
    assert_response :success
    assert_not_nil assigns(:top_5_recipes)
  end

  test "found_recipes with valid words assigns top and other recipes" do
    get found_recipes_path, params: { query: "cheese egg" }
    assert_response :success
    assert_not_nil assigns(:top_recipes)
    assert_not_nil assigns(:other_recipes)
  end

  test "found_recipes with empty query renders flash message" do
    get found_recipes_path, params: { query: "" }
    assert_response :success
    assert_nil assigns(:top_recipes)
  end

end
