class CreateSensors < ActiveRecord::Migration[7.1]
  def change
    create_table :sensors do |t|
      t.integer :fill_percent

      t.timestamps
    end
  end
end
