class CreateJoinEventSensors < ActiveRecord::Migration[7.1]
  def change
    create_table :join_event_sensors do |t|
      t.references :event, null: false, foreign_key: true
      t.references :sensor, null: false, foreign_key: true

      t.timestamps
    end
  end
end
