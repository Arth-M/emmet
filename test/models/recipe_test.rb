require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "top_5 returns 5 recipes ordered by rating" do
    results = Recipe.top_n(5)
    assert_equal 5, results.length
    assert results.first.rating >= results.last.rating
  end
  test "top_10 returns 10 recipes ordered by rating" do
    results = Recipe.top_n(10)
    assert_equal 10, results.length
    assert results.first.rating >= results.last.rating
  end

  test "search returns recipes" do
    results = Recipe.search(["cheese", "egg"])
    assert results.any?
    assert results.all? { |r| r.is_a?(Recipe) }
  end

  test "search returns empty array for blank words" do
    assert_equal [], Recipe.search([])
  end

  test "search returns at most 100 recipes" do
    results = Recipe.search(["cheese"])
    assert results.map(&:id).uniq.length <= 100
    results = Recipe.search(["salt"])
    assert results.map(&:id).uniq.length <= 100
  end
end
