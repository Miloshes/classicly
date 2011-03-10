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
  
  validates :name, :presence => true
  validates :book_type, :presence => true
  validates :collection_type, :presence => true
  validates :source_type, :presence => true
  validates :source, :presence => true

  has_friendly_id :name, :use_slug => true

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

end
