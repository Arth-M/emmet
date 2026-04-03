class CreateCapacities < ActiveRecord::Migration[7.1]
  def change
    create_table :capacities do |t|
      t.integer :liters

      t.timestamps
    end
  end
end
