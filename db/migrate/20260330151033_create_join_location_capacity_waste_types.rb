class CreateJoinLocationCapacityWasteTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :join_location_capacity_waste_types do |t|
      t.references :location, null: false, foreign_key: true
      t.references :capacity, null: false, foreign_key: true
      t.references :waste_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
