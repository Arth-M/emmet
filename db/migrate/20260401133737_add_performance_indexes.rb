class AddPerformanceIndexes < ActiveRecord::Migration[7.1]
  def change
    add_index :events, [:location_id, :event_type]
    add_index :incidents, :resolved_at
    add_index :incidents, :resolved
    add_index :events, :occurred_at
  end
end
