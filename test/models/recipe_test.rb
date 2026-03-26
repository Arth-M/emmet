require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "search returns recipes matching ingredients" do
    results = Recipe.search(["cheese", "egg"])
    assert results.any?
    assert results.all? { |r| r.is_a?(Recipe) }
  end

  test "search returns empty array for blank words" do
    assert_equal [], Recipe.search([])
  end

  test "search returns at most 100 recipes" do
    results = Recipe.search(["cheese"])
    assert results.length <= 100
  end
end
