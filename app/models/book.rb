include AWS::S3

class Book < ActiveRecord::Base
  include Descriptable
  belongs_to :author
  belongs_to :custom_cover
  
  has_many :collection_book_assignments
  has_many :collections, :through => :collection_book_assignments
  has_and_belongs_to_many :genres
  has_many :download_formats
  has_many :reviews, :as => :reviewable

  scope :available, where({:available => true})
  scope :blessed, where({:blessed => true})
  scope :with_description, where('description is not null')
  scope :random, lambda { |limit| {:order => 'RANDOM()', :limit => limit }}

  validates :title, :presence => true
  has_friendly_id :pretty_title, :use_slug => true

  def self.available_in_formats(formats)
    find_each do |book|
      available = (book.classicly_formats & formats).count > 0
      book.update_attribute(:available, available)
    end
  end
  
  def self.search(search_term, page_num)
    self.joins(:collections).joins(:author).where({:title.matches => "%#{search_term}%"} | 
    {:collections => {:name.matches => "%#{search_term}%"}} |
    {:author => {:name.matches => "%#{search_term}%"}}).select('DISTINCT books.*').page(page_num).per(10)
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

  def classicly_formats
    ['pdf', 'azw', 'rtf'] & self.all_downloadable_formats
  end

  def description_for_open_graph
    "Download %s for free on Classicly - available as Kindle, PDF, Sony Reader, iBooks and more, or simply read online to your heart’s content." % self.pretty_title 
  end
  
  def web_title
    if (self.pretty_title.length  + self.author.name.length) <= 100
      title, author = self.pretty_title, self.author.name
    else
      title, author = shorten_title(self.pretty_title, 49), shorten_title(self.author.name, 49)
    end
    "%s by %s - Read Online and Download Free Books" % [title, author]
  end

  def shorten_title(str, limit)
    return str if str.length <= limit
    str.slice(0, (limit - 3)).concat("...")
  end

  def find_fake_related(num = 8)
    result = []
    
    # Two sources for related books:
    #  - popular books from the same genres with the same language
    #  - other books of the author with the same language
    
    # == Popular books from the same genres (and same language)
    books_from_same_genre = []
    self.genres.each do |genre|
      # TODO: we don't have download counts yet, should sort by that when we have
      popular_books = genre.books.where("language = ? AND id <> ?", self.language, self.id).limit(200)
      books_from_same_genre += popular_books
    end
    
    # == Other books of the author, with the same language
    books_from_same_author = self.author.books.where("language = ? AND id <> ?",  self.language, self.id)
    
    # for 8 books requested we get 2 from the same author, for 2 we get 1
    num_of_books_to_get_from_same_author = (num / 4.0).ceil
    
    1.upto num_of_books_to_get_from_same_author do
      break if books_from_same_author.blank?
      
      position = rand(books_from_same_author.size)
      result << books_from_same_author[position]
      books_from_same_author.delete_at(position)
    end
    
    1.upto num-result.size do
      position = rand(books_from_same_genre.size)
      result << books_from_same_genre[position]
      books_from_same_genre.delete_at(position)
    end
    
    result.compact!
    result.sort_by { rand }
    
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
      result << books_to_choose_from[position]
      books_to_choose_from.delete_at(position)
    end
    
    # == books from the same author as a fallback
    
    books_to_choose_from = self.author.books.where("id <> ?", self.id)
    
    1.upto num-result.size do
      break if books_to_choose_from.blank?
      
      position = rand(books_to_choose_from.size)
      result << books_to_choose_from[position]
      books_to_choose_from.delete_at(position)
    end

    # == blessed books
    books_to_choose_from = Book.where("id <> ? AND blessed = ?", self.id, true)
    
    1.upto num-result.size do
      break if books_to_choose_from.blank?
      
      position = rand(books_to_choose_from.size)
      result << books_to_choose_from[position]
      books_to_choose_from.delete_at(position)
    end
    
    return result
  end

  def set_average_rating
    self.avg_rating = self.reviews.blank? ? 0 : (self.reviews.sum('rating').to_f / self.reviews.size.to_f).round
    self.save
  end
  
  def has_rating?
    self.avg_rating > 0
  end

  def belongs_to_author_collection?
    return Collection.exists?(:cached_slug => self.author.cached_slug)
  end

  def needs_canonical_link?
    (self.cached_slug =~ /--[\d]+/) != nil
  end

  def canonical_slug
    end_of_string = self.cached_slug =~ /--[\d]+/
    self.cached_slug[0, end_of_string]
  end
  
  def self.update_description_from_web_api(data)
    book  = Book.find(data['book_id'].to_i)
    return if book.blank?
    
    puts " -- updating book description: #{book.id}"
    book.update_attributes(:description => data['description'])
  end
end
