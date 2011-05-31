class AddMetaDescriptionToBlogPosts < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :meta_description, :string
  end

  def self.down
    remove_column :blog_posts, :meta_description
  end
end
