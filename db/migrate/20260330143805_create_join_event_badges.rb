class CreateJoinEventBadges < ActiveRecord::Migration[7.1]
  def change
    create_table :join_event_badges do |t|
      t.references :event, null: false, foreign_key: true
      t.references :badge, null: false, foreign_key: true

      t.timestamps
    end
  end
end
