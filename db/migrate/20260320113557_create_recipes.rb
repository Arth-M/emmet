class CreateRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :recipes do |t|
      t.string :title
      t.integer :cook_time
      t.integer :prep_time
      t.integer :total_time
      t.float :rating
      t.text :image
      t.string :author
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
