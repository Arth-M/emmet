class MigrateDateColumnsToDatetime < ActiveRecord::Migration[7.1]
  def up
    change_column :events,    :occurred_at, :datetime, using: "occurred_at::timestamptz"
    change_column :incidents, :resolved_at, :datetime, using: "resolved_at::timestamptz"
    change_column :badges,    :issued_at,   :datetime, using: "issued_at::timestamptz"
  end

  def down
    change_column :events,    :occurred_at, :string
    change_column :incidents, :resolved_at, :string
    change_column :badges,    :issued_at,   :string
  end
end
