class AddBlogPostIdToCustomResources < ActiveRecord::Migration
  def self.up
    add_column :custom_resources, :blog_post_id, :integer
  end

  def self.down
    remove_column :custom_resources, :blog_post_id
  end
end
