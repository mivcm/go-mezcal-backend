class CreateBlogPosts < ActiveRecord::Migration[7.2]
  def change
    create_table :blog_posts do |t|
      t.string :title
      t.string :slug
      t.string :excerpt
      t.text :content
      t.string :cover_image
      t.date :date
      t.string :category
      t.boolean :featured
      t.text :tags, array: true, default: []

      t.timestamps
    end
  end
end
