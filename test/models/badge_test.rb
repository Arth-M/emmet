require "test_helper"

class BadgeTest < ActiveSupport::TestCase
    test "badge_id est obligatoire" do
    assert_raises(ActiveModel::StrictValidationFailed) do
      Badge.new(issued_at: Time.current, badge_provider: BadgeProvider.first).validate!
    end
  end

  test "badge_id doit être unique" do
    existing = Badge.first
    skip "Pas de Badge dans le seed" unless existing

    dup = Badge.new(
      badge_id:       existing.badge_id,
      issued_at:      Time.current,
      badge_provider: existing.badge_provider
    )
    assert_raises(ActiveModel::StrictValidationFailed) { dup.validate! }
  end

  test "un badge appartient à un badge_provider" do
    badge = Badge.first
    skip "Pas de Badge dans le seed" unless badge
    assert_not_nil badge.badge_provider
  end
end
