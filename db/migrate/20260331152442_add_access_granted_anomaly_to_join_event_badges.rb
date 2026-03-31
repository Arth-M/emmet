class AddAccessGrantedAnomalyToJoinEventBadges < ActiveRecord::Migration[7.1]
  def change
    add_column :join_event_badges, :access_granted, :boolean
    add_column :join_event_badges, :anomaly_flags, :string, default: [], array: true
  end
end
