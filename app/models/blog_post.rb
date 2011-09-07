class BlogPost < ActiveRecord::Base
  has_many :author_quotings
  has_many :authors, :through => :author_quotings
  has_many :custom_resources
  has_one :seo_slug,  :as => :seoable
  # we defined a finder sql because we don't need every field in the book model
  has_and_belongs_to_many :related_books,
                          :class_name =>  'Book',
                          :join_table =>  'blog_posts_books',
                          :finder_sql =>  proc {"SELECT books.id, books.author_id, books.cached_slug,books.pretty_title " +
                                          "FROM books INNER JOIN blog_posts_books " +
                                          "ON books.id = blog_posts_books.book_id " + 
                                          "WHERE blog_posts_books.blog_post_id = #{id}" }
  validates_presence_of :meta_description
  accepts_nested_attributes_for :custom_resources, :allow_destroy => true
  after_save :generate_seo_slug, :create_author_quotings
  has_friendly_id :blog_post_slug, :use_slug => true, :strip_non_ascii => true

  state_machine :state, :initial => :draft do
    event :publish do
      transition :draft => :published
    end
    event :archive do
      transition :published => :archived
    end
    event :unarchive do
      transition :archived => :published
    end
  end

  def self.persist(blog_post, params)
    if params[:title].blank?
      blog_post.errors.merge!(:title => 'must be present for realsies!')
      return false
    end
    blog_post.update_attributes(params)
  end

  # CLEANUP: seo related, should be extracted
  def blog_post_slug
    self.title.downcase.rstrip.gsub(' ', '-')
  end

  def create_author_quotings
    AuthorQuoting.where(:blog_post_id => self.id).delete_all
    doc = Nokogiri::HTML(self.content)
    doc.xpath("//featured").each do|quotation|
      collection_id = doc.xpath('//featured').first.attributes['collection_id'].value
      text = doc.xpath('//featured').first.children.text
      AuthorQuoting.create(:collection_id => collection_id, :blog_post_id => self.id, :quoted_text => text)
    end
  end

  # CLEANUP: seo related, should be extracted
  def generate_seo_slug
    SeoSlug.create(:seoable => self, :slug => self.friendly_id, :format => 'post')
  end
end
