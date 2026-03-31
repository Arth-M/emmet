class RemoveAccesGrantedAnomalyFromBadges < ActiveRecord::Migration[7.1]
  def change
    remove_column :badges, :access_granted, :boolean
    remove_column :badges, :anomaly_flags, :string
  end
end
