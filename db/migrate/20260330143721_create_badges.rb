class CreateBadges < ActiveRecord::Migration[7.1]
  def change
    create_table :badges do |t|
      t.string :badge_id
      t.string :issued_at
      t.boolean :badge_revoked
      t.boolean :access_granted
      t.string :anomaly_flags, array: true, default: []
      t.references :badge_provider, null: false, foreign_key: true

      t.timestamps
    end
  end
end
