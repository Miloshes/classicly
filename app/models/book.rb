include AWS::S3

class Book < ActiveRecord::Base
  include Sluggable, SeoMethods, CommonBookMethods

  belongs_to :author
  belongs_to :custom_cover

  has_many :collection_book_assignments
  has_many :collections, :through => :collection_book_assignments
  has_many :download_formats
  has_and_belongs_to_many :genres
  has_many :reviews, :as => :reviewable
  has_many :seo_slugs, :as => :seoable
  has_many :book_pages

  scope :available, where({:available => true})
  scope :blessed, where({:blessed => true})
  scope :order_by_author, joins(:author) & Author.order('name')
  scope :with_description, where('description is not null')
  scope :random, lambda { |limit| {:order => (Rails.env.production? || Rails.env.staging?) ? 'RANDOM()': 'RAND()', :limit => limit }}

  validates :title, :presence => true
  has_friendly_id :optimal_friendly_id, :use_slug => true, :strip_non_ascii => true

  def self.available_in_formats(formats)
    find_each do |book|
      available = (book.classicly_formats & formats).count > 0
      book.update_attribute(:available, available)
    end
  end
  
  def self.books_from_random_collection(type, minimum_existing_books = 7, select_fields = ['books.id'])
    collections = case type
    when 'all'
      Collection.book_type.select{|collection| collection.books.count >= minimum_existing_books}
    when 'author'
      Collection.book_type.by_author.select{|collection| collection.books.count >= minimum_existing_books}
    when 'collection'
      Collection.book_type.by_collection.select{|collection| collection.books.count >= minimum_existing_books}
    end
    index = rand(collections.count)
    collection = collections[index]
    # return collection and books
    fields = select_fields.join(',')
    [collection, self.joins("INNER JOIN collection_book_assignments ON books.id = collection_book_assignments.book_id WHERE 
      ((collection_book_assignments.collection_id = #{collection.id}))").select(fields).limit(minimum_existing_books)]
  end
  
  def self.cover_url(book_id, size)
    "http://spreadsong-book-covers.s3.amazonaws.com/book_id#{book_id}_size#{size}.jpg"
  end

  def self.hashes_for_JSON(books)
    results = []
    books.each do|book|
      results << book.attributes.merge( {:author_slug => book.author.cached_slug } )
    end
    results
  end

  def self.search(search_term, current_page)
    self.joins('LEFT OUTER JOIN collection_book_assignments ON books.id = collection_book_assignments.book_id').
        joins('LEFT OUTER JOIN collections ON collections.id = collection_book_assignments.collection_id').
        joins(:author).where({:title.matches => "%#{search_term}%"} |
    {:collections => {:name.matches => "%#{search_term}%"}} |
    {:author => {:name.matches => "%#{search_term}%"}}).select('DISTINCT books.*').page(current_page).per(10)
  end

  def self.update_description_from_web_api(data)
    book  = Book.find(data['book_id'].to_i)
    return if book.blank?
    book.update_attributes(:description => data['description'])
  end

  def available_in_format?(format)
    ! self.download_formats.where({:format => format, :download_status => 'downloaded'}).blank?
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
    AWS::S3::Base.establish_connection!(
        :access_key_id     => APP_CONFIG['amazon']['access_key'],
        :secret_access_key => APP_CONFIG['amazon']['secret_key']
      )

    object_key = "#{self.id}.#{format}"
    S3Object.value(object_key, APP_CONFIG['buckets']['books'])
  end

  def all_downloadable_formats
    self.download_formats.all(:conditions => ['download_status = ?', 'downloaded'], :select => ['format']).map{|format| format.format}
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

  def description_for_open_graph
    "Download %s for free on Classicly - available as Kindle, PDF, Sony Reader, iBooks and more, or simply read online to your heart's content." % self.pretty_title
  end

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


    1.upto ( num - result.size ) do
      position = rand(books_from_same_genre.size)
      result << books_from_same_genre.delete_at(position)
    end

    result.compact! # gets rid of nil elements
    return result
  end

  # NOTE: in case the result set is empty, it should fall back to books from the same author, or just blessed books
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

    # == books from the same author as a fallback

    books_to_choose_from = self.author.books.where("id <> ?", self.id)

    1.upto num-result.size do
      break if books_to_choose_from.blank?
      position = rand(books_to_choose_from.size)
      result << books_to_choose_from.delete_at(position)
    end

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
    formats.each do |format|
      slug = format == 'online' ? optimal_url_for_read_online_page : optimal_url_for_download_page(format)
      SeoSlug.find_or_create_by_slug(slug, {:seoable_id => self.id, :seoable_type => self.class.to_s, :format => format})
    end
  end

  def has_rating?
    self.avg_rating > 0
  end

  def log_book_view_in_mix_panel(user_id, mix_panel_object)
    mix_panel_properties = {:title => self.pretty_title}
    if user_id
      mix_panel_properties.merge!({:id => user_id})
    end
    mix_panel_object.track_event("Viewed Book", mix_panel_properties)
  end

  def needs_canonical_link?
    (self.cached_slug =~ /--[\d]+/) != nil
  end

  def on_download(user_id, mix_panel_object)
    Book.update_counters self.id, :downloaded_count => 1
    mix_panel_properties = {:book => self.pretty_title}
    if user_id
      mix_panel_properties.merge!({:id => user_id})
    end
    mix_panel_object.track_event("Download Book", mix_panel_properties) if Rails.env.production?
  end

  def optimal_friendly_id
    return self.pretty_title if self.pretty_title.length <= 75
    self.pretty_title[0, 75]
  end

  def optimal_url_for_read_online_page
    extra = 'read-online-free'
    str = self.cached_slug.clone
    if [extra, str, uniqueness_indicator].map(&:length).reduce(:+) > 75 # sums every part of the url lengths
      limit = 75 - extra.length - uniqueness_indicator.length #limit the str length
      str = str[0, limit]
    end
    str << "-" if str[-1, 1] != '-'
    "read-#{str}online-free"
  end

  def read_online_title
    extra = "Read Online Free"
    book_title = self.pretty_title
    if [extra, self.pretty_title].map(&:length).reduce(:+) > 70
      book_title = shorten_title self.pretty_title, (70 - extra.length)
    end
    "Read #{book_title} Online Free"
  end

  def set_average_rating
    self.avg_rating = self.reviews.blank? ? 0 : (self.reviews.sum('rating').to_f / self.reviews.size.to_f).round
    self.save
  end

  def shorten_title(limit)
    return self.pretty_title if self.pretty_title.length <= limit
    self.pretty_title.slice(0, (limit - 3)).concat("...")
  end

  def view_book_page_title
    if [self.pretty_title ,' by ' , self.author.name].map(&:length).reduce(:+) <= 70
      "#{self.pretty_title} by #{self.author.name}"
    elsif self.pretty_title.length <= 70
      self.pretty_title
    else
      shorten_title 70
    end
  end
end
