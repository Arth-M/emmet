class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations do |t|
      t.string :id_pav
      t.string :name
      t.text :address
      t.string :city
      t.integer :zip
      t.string :lat
      t.string :lng

      t.timestamps
    end
  end
end
