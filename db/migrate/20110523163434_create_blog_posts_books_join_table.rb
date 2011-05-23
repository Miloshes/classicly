class CreateBlogPostsBooksJoinTable < ActiveRecord::Migration
  def self.up
    create_table :blog_posts_books, :id => false do |t|
      t.integer :blog_post_id
      t.integer :book_id
    end
  end

  def self.down
    drop_table :blog_posts_books
  end
end
