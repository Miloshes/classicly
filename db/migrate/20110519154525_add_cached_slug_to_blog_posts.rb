class AddCachedSlugToBlogPosts < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :cached_slug, :string
    add_index :blog_posts, :cached_slug, :unique => true
  end

  def self.down
    remove_column :blog_posts, :cached_slug
  end
end