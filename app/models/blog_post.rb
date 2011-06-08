class BlogPost < ActiveRecord::Base
  has_many :custom_resources
  has_one :seo_slug,  :as => :seoable
  # we defined a finder sql because we don't need every field in the book model
  has_and_belongs_to_many :related_books,
                          :class_name =>  'Book',
                          :join_table =>  'blog_posts_books',
                          :finder_sql =>  'SELECT books.id, books.author_id, books.cached_slug,books.pretty_title ' +
                                          'FROM books INNER JOIN blog_posts_books ' +
                                          'ON books.id = blog_posts_books.book_id ' + 
                                          'WHERE blog_posts_books.blog_post_id = #{id}'
  validates_presence_of :meta_description
  accepts_nested_attributes_for :custom_resources, :allow_destroy => true
  after_save :generate_seo_slug
  has_friendly_id :blog_post_slug, :use_slug => true, :strip_non_ascii => true
  
  def self.persist(blog_post, params)
    if params[:title].blank?
      blog_post.errors.merge!(:title => 'must be present for realsies!')
      return false
    end
    blog_post.update_attributes(params)
  end
                              
  def blog_post_slug
    self.title.downcase.rstrip.gsub(' ', '-')
  end
  
  def generate_seo_slug
    SeoSlug.create(:seoable => self, :slug => self.friendly_id, :format => 'post')
  end
end
