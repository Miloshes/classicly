class CreateBlogPosts < ActiveRecord::Migration
  def self.up
    unless table_exists? :blog_posts 
      create_table :blog_posts do |t|
        t.string :title
        t.text :content
        t.string :keywords

        t.timestamps
      end
    end
  end

  def self.down
    drop_table :blog_posts
  end
end
