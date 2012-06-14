# CLEANUP: extract seo slug related functionality

include AWS::S3

class Collection < ActiveRecord::Base
  # we have to be able to handle URLs in the model
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers
  include CommonSeoDefaultsMethods

  # books
  has_many  :audiobooks, :through => :collection_audiobook_assignments
  has_many  :books, :through => :collection_book_assignments
  has_many  :collection_audiobook_assignments
  has_many  :collection_book_assignments
  has_many  :featured_audiobooks, :through => :featured_collection_audiobook_assignments, :source => :audiobook

  # featured books
  has_many  :featured_collection_book_assignments,
            :class_name => 'CollectionBookAssignment',
            :conditions => {:featured => true}

  has_many  :featured_books, :through => :featured_collection_book_assignments, :source => :book

  has_many  :featured_collection_audiobook_assignments,
            :class_name => 'CollectionAudiobookAssignment',
            :conditions => {:featured => true}

  has_many  :quotes
  has_many  :seo_slugs, :as => :seoable
  has_one   :seo_info, :as => :infoable
  has_one   :audio_collection, :class_name => 'Collection', :foreign_key => :audio_collection_id
  
  belongs_to :genre
  belongs_to :book_collection, :class_name => 'Collection', :foreign_key => :audio_collection_id
  
  scope :find_audiobook_collections_and_genres, where(:book_type => 'audiobook', :collection_type.in => ['collection', 'genre'])
  scope :find_audiobook_author_collections, where(:book_type => 'audiobook', :collection_type => 'author')
  scope :find_book_collections_and_genres, where(:book_type => 'book', :collection_type.in => ['collection', 'genre'])
  scope :find_book_author_collections, where(:book_type => 'book', :collection_type => 'author')
  scope :of_type, lambda {|type| where(:book_type => type)}
  scope :random, lambda {|limit| order('RANDOM()').limit(limit) }
  scope :with_description, where(:description.not_eq => '')

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
      case collection.book_type
        when 'book'
          collection.update_attribute :downloaded_count, collection.books.sum(:downloaded_count)
        when 'audiobook'
          collection.update_attribute :downloaded_count, collection.audiobooks.sum(:downloaded_count)
      end
    end
  end

  # def audiobook_collection_book_slug
  #     return nil if !has_book_counterpart?
  #     Collection.where(:name => self.name, :book_type => 'book').select('cached_slug').first.cached_slug
  #   end

  def author
    Author.where(:cached_slug => self.cached_slug).first
  end

  def has_author?
    Author.exists?(:cached_slug => self.cached_slug)
  end

  def featured_book
    self.books.select{|book| book.blessed}.first || self.books.first
  end

  def featured_audiobook
    self.audiobooks.select{|audiobook| audiobook.blessed}.first || self.audiobooks.first
  end

  def get_paginated_books(parameters)
    method      = self.book_type.pluralize.to_sym # either calls the method 'books' or 'audiobooks'
    order_query = 'downloaded_count desc'

    if parameters[:sort]
      query_segments  = parameters[:sort].split('_')
      field           = query_segments[0..1].join('_')
      order_query     = ([field] + [query_segments.last]).join(' ') # has to be in the most_downloaded asc format
    end

    self.send(method).order(order_query).page(parameters[:page]).per(10)
  end

  def has_author_portrait?
    !self.author_portrait_updated_at.blank?
  end

  def has_audio_collection?
    return false if self.book_type == 'audiobook'
    self.audio_collection != nil
  end
  
  def belongs_to_book_collection?
    return false if self.book_type == 'book'
    self.book_collection != nil
  end

  # def has_book_counterpart?
  #     return false if self.book_type == 'book'
  #     Collection.exists?(:name => self.name , :book_type => 'book')
  #   end

  def is_audio_collection?
    self.book_type == 'audiobook'
  end

  def is_book_collection?
    self.book_type == 'book'
  end

  def is_author_collection?
    self.collection_type == 'author'
  end

  # CLEANUP: needs refactoring, not even sure what it stands for
  def needs_canonical_link?(per_page)
    per_page < self.send(self.book_type.pluralize.to_sym).count 
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

  def thumbnail_books(n_books)
    if self.book_type == 'book'
      self.books[0..(n_books - 1)] - [self.featured_book]
    else
      self.audiobooks[0..(n_books - 1)] - [self.featured_audiobook]
    end
  end
  
end
