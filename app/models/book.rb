include AWS::S3

# CLEANUP: extract related book, rating and seo related methods, group and document the rest

class Book < ActiveRecord::Base
  include Sluggable, SeoMethods, CommonBookMethods, CommonSeoDefaultsMethods

  belongs_to :author
  # CLEANUP: remove. We don't even have a model like that.
  belongs_to :custom_cover

  has_many :library_books
  has_many :libraries, :through => :library_books
  
  # CLEANUP: rename to related_blog_posts
  has_and_belongs_to_many :blog_posts, :join_table => 'blog_posts_books'
  
  has_many :collection_book_assignments
  has_many :collections, :through => :collection_book_assignments
  
  has_many :download_formats
  
  # CLENAUP: can be removed. Obsolete model
  has_and_belongs_to_many :genres
  
  has_many :reviews, :as => :reviewable
  has_many :anonymous_reviews, :as => :reviewable
  
  has_many :book_highlights
  has_many :anonymous_book_highlights
  
  has_one :seo_info, :as => :infoable
  has_many :seo_slugs, :as => :seoable
  
  has_many :book_pages

  delegate :cached_slug, :name, :to => :author, :prefix =>  true

  scope :available, where({:available => true})
  scope :blessed, where({:blessed => true})
  scope :for_author, lambda {|author| where(:author_id => author.id)}
  scope :order_by_author, joins(:author) & Author.order('name')
  scope :with_description, where('description is not null')
  scope :random, lambda { |limit| {:order => "RANDOM()", :limit => limit } }
  scope :search_in_ids, lambda {|ids| where(:id.in => ids) }

  validates :title, :presence => true

  has_friendly_id :optimal_friendly_id, :use_slug => true, :strip_non_ascii => true
  
  # instance variables to help rendering the book content
  attr_accessor :book_content, :reader_engine

  def self.available_in_formats(formats)
    find_each do |book|
      available = (book.classicly_formats & formats).count > 0
      book.update_attribute(:available, available)
    end
  end
  
  def self.cover_url(book_id, size)
    "http://spreadsong-book-covers.s3.amazonaws.com/book_id#{book_id}_size#{size}.jpg"
  end

  def self.search(search_term, current_page, per_page= 25)
    self.where(:pretty_title.matches => "%#{search_term}%").page(current_page).per(per_page)
    # self.joins('LEFT OUTER JOIN collection_book_assignments ON books.id = collection_book_assignments.book_id').
    #         joins('LEFT OUTER JOIN collections ON collections.id = collection_book_assignments.collection_id').
    #         joins(:author).where({:title.matches => "%#{search_term}%"} |
    #     {:collections => {:name.matches => "%#{search_term}%"}} |
    #     {:author => {:name.matches => "%#{search_term}%"}}).select('DISTINCT books.*').page(current_page).per(10)
  end

  def self.update_description_from_web_api(data)
    book  = Book.find(data['book_id'].to_i)
    return if book.blank?
    book.update_attributes(:description => data['description'])
  end

  def available_in_format?(format)
    format = 'azw' if (format == 'kindle')
    ! self.download_formats.find_by_format_and_download_status(format, 'downloaded').nil?
  end

  def download_url_for_format(format)
    AWS::S3::Base.establish_connection!(
        :access_key_id     => APP_CONFIG['amazon']['access_key'],
        :secret_access_key => APP_CONFIG['amazon']['secret_key']
      )

    object_key = "#{self.id}.#{format}"
    # protected URL, expires in 5 mins
    S3Object.url_for(object_key, APP_CONFIG['buckets']['books'], :expires_in => 300)
  end

  # Reads the binary data from S3 for the book file. Needs the file format as a parameter
  def file_data_for_format(format)
    format = 'azw' if format == 'kindle'
    
    AWS::S3::Base.establish_connection!(
        :access_key_id     => APP_CONFIG['amazon']['access_key'],
        :secret_access_key => APP_CONFIG['amazon']['secret_key']
      )

    object_key = "#{self.id}.#{format}"
    S3Object.value(object_key, APP_CONFIG['buckets']['books'])
  end

  def last_bookmarked_page(library)
    if library.library_books.map(&:book_id).include?(self.id)
      library_book = library.library_books.find_by_book_id(self.id)
      page  = library_book.bookmarks.maximum('page_number') unless library_book.bookmarks.empty?
    end
    page || 1
  end

  def all_downloadable_formats
    self.download_formats.all(:conditions => ['download_status = ?', 'downloaded'], :select => ['format']).map{|format| format.format}
  end

  def audiobook_download_slug

    if self.has_audiobook
      audiobook = Audiobook.find_by_pretty_title self.pretty_title
      audiobook.nil? ? nil : audiobook.download_mp3_slug
    end

  end

  def belongs_to_author_collection?
    return Collection.exists?(:cached_slug => self.author.cached_slug)
  end

  def canonical_slug
    end_of_string = self.cached_slug =~ /--[\d]+/
    self.cached_slug[0, end_of_string]
  end

  def classicly_formats
    ['pdf', 'azw', 'rtf'] & self.all_downloadable_formats
  end

  # CLEANUP: could be extracted
  def find_fake_related(num = 8, select = nil)
    # determine if we need to select certain fields from book's table and convert to string
    select_fields = select.join(',') if select
    result = []
    # Two sources for related books:

    # Other books of the author, with the same language:
    books_from_same_author = select ? self.author.books.where( :language => self.language, :id.not_eq => self.id ).select( select_fields ) :
      self.author.books.where( :language => self.language, :id.not_eq => self.id )
    
    # for 8 books requested we get 2 from the same author, for 2 we get 1:
    num_of_books_to_get_from_same_author = ( num < 4 ) ? 1 :  ( num / 4.0 ).ceil 

    1.upto num_of_books_to_get_from_same_author do
      break if books_from_same_author.blank? #  break if the array has been emptied
      position = rand( books_from_same_author.size )
      result << books_from_same_author.delete_at( position )
    end

    # Popular books from the same genres (and same language):
    books_from_same_genre = []
    self.genres.each do |genre|
      books_from_same_genre += select ? genre.books.where( :language => self.language, :id.not_eq =>  self.id ).select( select_fields ).limit( 25 ) : 
        genre.books.where(:language => self.language, :id.not_eq => self.id).limit( 25 )
    end


    1.upto( num - result.size ) do
      position = rand(books_from_same_genre.size)
      result << books_from_same_genre.delete_at(position)
    end

    result.compact! # gets rid of nil elements
    return result
  end

  # CLEANUP: could be extracted
  # NOTE: in case the result set is empty, it should fall back to books from the same author, or just blessed books
  # NOTE: Due to lazy loading of associations the return result statements doesn't speed up the app, but they show the fallback structure
  def find_more_from_same_collection(num = 2)
    result = []

    # == books from the same collection
    books_to_choose_from = []
    self.collections.each do |collection|
      books_to_choose_from += collection.books.where("books.id <> ?", self.id)
    end

    1.upto num do
      break if books_to_choose_from.blank?
      position = rand(books_to_choose_from.size)
      result << books_to_choose_from.delete_at(position)
    end
    
    return result if result.size == num

    # == books from the same author as a fallback

    books_to_choose_from = self.author.books.where("id <> ?", self.id)

    1.upto num-result.size do
      break if books_to_choose_from.blank?
      position = rand(books_to_choose_from.size)
      result << books_to_choose_from.delete_at(position)
    end
    
    return result if result.size == num

    # == blessed books
    books_to_choose_from = Book.where("id <> ? AND blessed = ?", self.id, true)

    1.upto num-result.size do
      break if books_to_choose_from.blank?
      position = rand(books_to_choose_from.size)
      result << books_to_choose_from.delete_at(position)
    end
    
    return result
  end

  def generate_seo_slugs(formats)
    # formats can be -> pdf, kindle or online:
    formats.each do |format|
      slug = (format == 'online') ? optimal_url_for_read_online_page : optimal_url_for_download_page(format)
      SeoSlug.find_or_create_by_slug(slug, {:seoable_id => self.id, :seoable_type => self.class.to_s, :format => format})
    end
  end

  def has_rating?
    self.avg_rating > 0
  end

  def needs_canonical_link?
    (self.cached_slug =~ /--[\d]+/) != nil
  end

  def optimal_friendly_id
    return self.pretty_title if self.pretty_title.length <= 75
    self.pretty_title[0, 75]
  end

  def optimal_url_for_read_online_page
    url_parts = URL_CONFIG['root_path'] + 'read-online-free'
    str = self.cached_slug.clone
    if [url_parts, str, uniqueness_indicator].map(&:length).reduce(:+) > 115 # sums every part of the url lengths.
      limit = 115 - url_parts.length - uniqueness_indicator.length #limit the str length
      str = str[0, limit]
    end
    str << "-" if str[-1, 1] != '-'
    "read-#{str}online-free"
  end
  
  # CLEANUP: REMOVE
  # NOTE: we should remove this. It's shorter, but it's actually harder to figure out what it does
  def read_online?
    self.is_rendered_for_online_reading == true
  end


  def set_average_rating
    self.avg_rating = average_rating
    self.save
  end

  def update_seo_slugs
    SeoSlug.where(:seoable_id => self.id).delete_all
    generate_seo_slugs(['pdf', 'kindle', 'online'])
  end
  
  # Returns an array of file formats prettied up for public display (turns azw into Kindle, pdf into PDF).
  # The book is available for download in all these formats.
  def pretty_download_formats
    return classicly_formats.collect { |format|
      case format
      when "azw"
        "Kindle"
      when "pdf"
        "PDF"
      when "rtf"
        "Rtf"
      else
        format
      end
    }
  end

  # === Methods related to online reading and rendering

  # The whole content of the book in plain-text format, fetched from the S3 bucket.
  # NOTE: this is used by the rendering algorithms, and takes a couple of seconds on the first call
  def book_content
    @book_content ||= reader_engine.get_book(self.id)
  end

  def reader_engine
    @reader_engine ||= ReaderEngine.new
  end

  # Based on it's book pages' renderdata (character ranges for the pages), it fills up the book pages with the actual book content
  # TODO: add a flag for indicating that the book is getting rendered
  def render_book_for_online_reading!
    self.book_pages.find_each do |book_page|
      book_page.render_page_content_from(book_content)
    end
    
    self.update_attributes(:is_rendered_for_online_reading => true)
  end
  
  # Removes the content from the book pages.
  # NOTE: gets called by the cleanup cron jobs. We only keep the popular books in the database.
  def wipe_book_pages!
    
    self.book_pages.find_each do |book_page|
      book_page.wipe_page_content!
    end
    
    self.update_attributes(:is_rendered_for_online_reading => false)
  end
  
end
