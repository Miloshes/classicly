class AddStateToBlogPosts < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :state, :string
  end

  def self.down
    remove_column :blog_posts, :state
  end
end
