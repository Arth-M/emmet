require "test_helper"

class BadgeProviderTest < ActiveSupport::TestCase
  test "name est obligatoire" do
    assert_raises(ActiveModel::StrictValidationFailed) { BadgeProvider.new.validate! }
  end

  test "name doit être unique" do
    existing = BadgeProvider.first
    skip "Pas de BadgeProvider dans le seed" unless existing

    dup = BadgeProvider.new(name: existing.name)
    assert_raises(ActiveModel::StrictValidationFailed) { dup.validate! }
  end

  test "un badge_provider répond à l'association badges" do
    assert_respond_to BadgeProvider.first, :badges
  end
end
