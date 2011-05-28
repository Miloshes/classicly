class BlogPost < ActiveRecord::Base
  has_friendly_id :blog_post_slug, :use_slug => true, :strip_non_ascii => true
  # we defined a finder sql because we don't need every field in the book model
  has_and_belongs_to_many :related_books,
                          :class_name =>  'Book',
                          :join_table =>  'blog_posts_books',
                          :finder_sql =>  'SELECT books.id, books.author_id, books.cached_slug,books.pretty_title ' +
                                          'FROM books INNER JOIN blog_posts_books ' +
                                          'ON books.id = blog_posts_books.book_id ' + 
                                          'WHERE blog_posts_books.blog_post_id = #{id}'
                              
  def blog_post_slug
    self.title.downcase.rstrip.gsub(' ', '-')
  end
end
