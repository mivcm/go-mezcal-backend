class ChangeTagsToTextArrayInBlogPosts < ActiveRecord::Migration[7.2]
  def up
    # Cambia la columna a text[] (array de texto) en PostgreSQL
    remove_column :blog_posts, :tags, :string
    add_column :blog_posts, :tags, :text, array: true, default: []
  end

  def down
    # Revertir a string simple
    remove_column :blog_posts, :tags, :text, array: true
    add_column :blog_posts, :tags, :string
  end
end
