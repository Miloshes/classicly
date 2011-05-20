class AddCachedSlugToBlogPosts < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :cached_slug, :string
  end

  def self.down
    remove_column :blog_posts, :cached_slug
  end
end
