class Collection < ActiveRecord::Base
  include Descriptable
  # books
  has_many :collection_book_assignments
  has_many :books, :through => :collection_book_assignments
  
  # featured books
  has_many :featured_collection_book_assignments,
           :class_name => 'CollectionBookAssignment',
           :conditions => {:featured => true}
  has_many :featured_books, :through => :featured_collection_book_assignments, :source => :book

  # audiobooks
  has_many :collection_audiobook_assignments
  has_many :audiobooks, :through => :collection_audiobook_assignments

  # featured audiobooks
  has_many :featured_collection_audiobook_assignments,
           :class_name => 'CollectionAudiobookAssignment',
           :conditions => {:featured => true}
  has_many :featured_audiobooks, :through => :featured_collection_audiobook_assignments, :source => :audiobook

  # genre
  belongs_to :genre
  default_scope :order => 'downloaded_count desc'
  scope :book_type, where(:book_type => 'book')
  scope :audio_book_type, where(:book_type => 'audiobook')
  scope :by_author, where(:collection_type => 'author')
  scope :by_collection, where(:collection_type => 'collection')
  
  validates :name, :presence => true
  validates :book_type, :presence => true
  validates :collection_type, :presence => true
  validates :source_type, :presence => true
  validates :source, :presence => true

  has_friendly_id :collection_slug, :use_slug => true

  has_attached_file :author_portrait, 
    :styles => {
      :thumb => {
          :geometry => "150x200#",
          :quality => 85,
          :format => 'jpg',
          :convert_options => '-strip'
        }
    },
    :storage => :s3,
    :s3_credentials => {
      :access_key_id => APP_CONFIG['amazon']['access_key'],
      :secret_access_key => APP_CONFIG['amazon']['secret_key']
    },
    :s3_permissions => 'public-read',
    :bucket => APP_CONFIG['buckets']['covers']['original_highres'],
    :path => ":id_:style.:extension"
  
  
  def self.options_for_book_type
    ["book", "audiobook"].collect { |name|
        ["#{name}", name]
      }
  end

  def self.options_for_collection_type
    ["author", "collection", "genre"].collect { |name|
        ["#{name}", name]
      }
  end
  
  def self.options_for_paperback_color
    PaperbackColor.all.collect { |name|
        ["#{name}", name]
      }
  end
  
  def self.options_for_source_type
    ["SQL", "DBCategory", "IDList"].collect { |name|
        ["#{name}", name]
      }
  end
  
  def self.update_cache_downloaded_count
    Collection.find_each do |collection|
      collection.update_attribute :downloaded_count, collection.books.sum(:downloaded_count)
    end
  end

  def has_author_portrait?
    !self.author_portrait_updated_at.blank?
  end

  def description_for_open_graph
    case self.collection_type
    when 'collection'
      "%s- the ultimate literature collection. Dozens of hand-picked books for free download as PDF, Kindle, Sony Reader, iBooks, and more. You can also read online!" % self.name
    when 'author'
      "The world’s greatest collection of books by %s. Download free books, read online, or check out %s quotes and a hand-picked collection of featured titles." % ([self.name] * 2)
    end
  end

  def web_title
    case self.collection_type
    when 'collection'
      "%s - Download Free Books, Read Online, and More " % self.name
    when 'author'
      "%s Books - Download %s free books, read online, and more" % ([self.name] * 2) 
    end
  end

  def random_blessed(num = 8, klass = :book)
    #TODO : refactor this with metaprogramming
    blessed_books = []
    if klass == :book
      return [] if self.books.blessed.blank?
      blessed_books = self.books.blessed.clone
    elsif klass == :audiobook
      return [] if self.audiobooks.blessed.blank?
      blessed_books = self.audiobooks.blessed.clone
    end

    num = blessed_books.count if num > blessed_books.count
    results = []
    1.upto num do
      position = rand(blessed_books.size)
      results << blessed_books[position]
      blessed_books.delete_at(position)
    end
    return results
  end

  def collection_slug
    case book_type
      when 'book'
        name
      when 'audiobook'
        if Collection.where(:name => name).count == 1
          name
        else
          "#{name}-audiobooks"
        end
    end
  end
end
