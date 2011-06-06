class Collection < ActiveRecord::Base
  # we have to be able to handle URLs in the model
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  # books
  has_many :audiobooks, :through => :collection_audiobook_assignments
  has_many :books, :through => :collection_book_assignments
  has_many :collection_audiobook_assignments
  has_many :collection_book_assignments
  has_many :featured_audiobooks, :through => :featured_collection_audiobook_assignments, :source => :audiobook

  # featured books
  has_many :featured_collection_book_assignments,
            :class_name => 'CollectionBookAssignment',
            :conditions => {:featured => true}

  has_many :featured_books, :through => :featured_collection_book_assignments, :source => :book

  has_many :featured_collection_audiobook_assignments,
           :class_name => 'CollectionAudiobookAssignment',
           :conditions => {:featured => true}

  has_many :seo_slugs, :as => :seoable
  has_one :seo_info, :as => :infoable

  belongs_to :genre
  
  scope :of_type, lambda {|type| where(:book_type => type)}
  scope :collection_type, lambda {|type| where(:collection_type => type)}
  scope :book_type, where(:book_type => 'book')
  scope :audio_book_type, where(:book_type => 'audiobook')
  scope :by_author, where(:collection_type => 'author')
  scope :by_collection, where(:collection_type => 'collection')
  scope :random, lambda { |limit| {:order => (Rails.env.production? || Rails.env.staging?) ? 'RANDOM()': 'RAND()', :limit => limit }}
  
  before_save :set_parsed_description
  
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
  
  def self.get_collection_books_in_json(collection_ids, type)
    type = type || 'book'
    data = []
    collection_ids.each do |id|
      # find the collection:
      current = Collection.find id
      # get 5 books (or audiobooks) to show:
      books = ( type == 'book' ) ? current.books.limit(5) : current.audiobooks.limit(5)
      # create the books data to be converted in json: 
      books_hash_array = books.map do |book|
        author_slug = Author.where(:id => book.author_id).select('cached_slug').first.cached_slug
        { :id => book.id, :cached_slug => book.cached_slug, :author_slug => author_slug }
      end
      # add the collection id to the data to be sent:
      data << {:collection_id => id, :books => books_hash_array} 
    end
    data
  end
  
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
  
  def self.search(search_term, current_page, per_page = 25)
    self.where(:name.matches => "%#{search_term}%").page(current_page).per(per_page)
  end
  
  def self.update_cache_downloaded_count
    Collection.find_each do |collection|
      case collection.book_type
        when 'book'
          collection.update_attribute :downloaded_count, collection.books.sum(:downloaded_count)
        when 'audiobook'
          collection.update_attribute :downloaded_count, collection.audiobooks.sum(:downloaded_count)
      end
    end
  end

  def has_author_portrait?
    !self.author_portrait_updated_at.blank?
  end

  def ajax_paginated_audiobooks(params)
    if params[:sort_by].nil?
      self.audiobooks.page(params[:page]).per(10)
    else
      params[:sort_by] == 'author' ? self.audiobooks.order_by_author.page(params[:page]).per(10) : 
        self.audiobooks.order(params[:sort_by]).page(params[:page]).per(10)
    end
  end

  def is_audio_collection?
    self.book_type == 'audiobook'  
  end
  
  def is_author_collection?
    self.collection_type == 'author'
  end

  def random_blessed(num = 8)
    blessed_books = []
    if self.book_type == 'book'
      blessed_books = self.books.blessed.clone
    elsif self.book_type == 'audiobook'
      blessed_books = self.audiobooks.blessed.clone
    end

    num = blessed_books.count if num > blessed_books.count

    results = []
    1.upto num do
      position = rand(blessed_books.size)
      results << blessed_books.delete_at(position) # delete_at returns the deleted element
    end
    return results
  end
  
  def collection_slug
    case self.book_type
      when 'book'
        name
      when 'audiobook'
        "#{name}-audiobooks"
    end
  end

  def generate_seo_slugs
    SeoSlug.create!({:slug => self.cached_slug, :seoable_id => self.id, :seoable_type => self.class.to_s, :format => 'all'})
    # for the moment we don't have these pages:
    # formats -> pdfs, kindle-books(books), mp3s for audiobooks
    # formats = (self.book_type == 'book') ? %w(pdfs kindle-books) : %w(mp3s)
    #     formats.each do |format|
    #       slug = "download-%s-%s" % [self.cached_slug, format]
    #       SeoSlug.create!({:slug => slug, :seoable_id => self.id, :seoable_type => self.class.to_s, :format => format})
    #     end
  end

  def limited_description(limit)
    return "" if self.description.nil?
    limit = self.description.length - 1 if limit >= self.description.length
    self.description[0..limit]
  end
  
  # turns the collection's description into HTML
  def set_parsed_description
    default_url_options[:host] = 'www.classicly.com'
    
    doc = Nokogiri::HTML(self.description)
    books_tags = doc.xpath("//book") # get all <book> tags
    
    books_tags.each do |book_tag|
      book_id = book_tag.attributes["id"].value.to_i
      book_object = Book.find(book_id)
      book_tag.name = "a"
      book_tag.set_attribute("href", author_book_url(book_object.author, book_object))
      book_tag.set_attribute("class", "description-link")
    end
    
    quotes = doc.xpath('//quote')
    quotes.each do|quote|
      quote.remove
    end
    
    self.parsed_description = doc.css('body').inner_html
  end
end
