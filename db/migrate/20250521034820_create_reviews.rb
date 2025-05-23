class CreateReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :reviews do |t|
      t.string :user_name
      t.string :user_image
      t.integer :rating
      t.text :comment
      t.datetime :date
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
