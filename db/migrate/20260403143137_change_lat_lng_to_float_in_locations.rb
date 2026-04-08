class ChangeLatLngToFloatInLocations < ActiveRecord::Migration[7.1]
  def change
    change_table :locations do |t|
      t.change :lat, :float, using: 'lat::double precision'
      t.change :lng, :float, using: 'lat::double precision'
    end
  end
end
