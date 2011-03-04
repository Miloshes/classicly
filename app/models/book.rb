include AWS::S3

class Book < ActiveRecord::Base
  include Descriptable
  belongs_to :author
  belongs_to :custom_cover
  
  has_many :collection_book_assignments
  has_many :collecions, :through => :collection_book_assignments
  has_and_belongs_to_many :genres
  has_many :download_formats

  scope :available, where({:available => true})
  scope :with_description, where('description is not null')

  validates :title, :presence => true

  def self.available_in_formats(formats)
    find_each do|book|
      available = (book.classicly_formats & formats).count > 0
      book.update_attribute(:available, available)
    end
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

  def all_downloadable_formats
    self.download_formats.all(:conditions => ['download_status = ?', 'downloaded'], :select => ['format']).map{|format| format.format}
  end

  def classicly_formats
    ['pdf', 'azw', 'rtf'] & self.all_downloadable_formats
  end
  
  def self.random_blessed_books(num = 8)
    blessed_books = self.where(:blessed => true)
    return [] if blessed_books.blank?
    
    result = []
    
    1.upto num do
      position = rand(blessed_books.size)
      result << blessed_books[position]
      blessed_books.delete_at(position)
      num = num-1 if num > 0
    end
      
    return result
  end
  
  def find_fake_related(num = 8)
    result = []
    
    # Two sources for related books:
    #  - popular books from the same genres with the same language
    #  - other books of the author with the same language
    
    # == Popular books from the same genres (and same language)
    books_from_same_genre = []
    self.genres.each do |genre|
      # TODO: we don't have download counts yet
      popular_books = genre.books.where("language = ? AND id <> ?", self.language, self.id).limit(200)
      books_from_same_genre << popular_books
    end
    
    books_from_same_genre.flatten!
    
    # == Other books of the author, with the same language
    books_from_same_author = self.author.books.where("language = ? AND id <> ?",  self.language, self.id)
    
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
  
end
