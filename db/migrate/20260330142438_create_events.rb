class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :log_id
      t.string :occurred_at
      t.references :location, null: false, foreign_key: true

      t.timestamps
    end
  end
end
