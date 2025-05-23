class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name
      t.string :slug
      t.string :category
      t.decimal :price
      t.text :description
      t.string :short_description
      t.float :abv
      t.integer :volume
      t.string :origin
      t.jsonb :ingredients
      t.boolean :featured
      t.boolean :new
      t.float :rating

      t.timestamps
    end
  end
end
