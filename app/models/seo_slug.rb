# CLEANUP: needs big renaming and method extraction. Rename to LandingPageSlug or something

class SeoSlug < ActiveRecord::Base
  include CommonSeoDefaultsMethods
  belongs_to :seoable, :polymorphic => true
  has_one :seo_info, :as => :infoable

  scope :kindle, where(:format => 'kindle')
  scope :mp3, where(:format => 'mp3')
  scope :pdf, where(:format => 'pdf')
  # CLEANUP: rename to readable_online or something
  scope :read_online, where(:format => 'online')

  # CLEANUP: is this used anywhere? We have a search model now
  def self.search(search_term, current_page, per_page = 25, type='book')
    indextank = IndexTankInitializer::IndexTankService.get_index('classicly_staging')
    documents = indextank.search "#{search_term} type:#{type}"
    docids = documents['results'].collect{|doc| doc['docid']}
    bookids = docids.collect {|docid| docid.split('_').last.to_i}
    bookids.compact!
    self.where(:seoable_id.in => bookids, :seoable_type => type.capitalize).page(current_page).per(per_page)
  end
  
  # CLEANUP: extract: these are collection related stuff
  def find_featured_book_for_collection
    return nil if self.seoable_type.nil? || self.seoable_type != 'Collection'
    self.seoable.book_type == 'audiobook' ? (self.seoable.audiobooks.blessed.first || self.seoable.audiobooks.first) :
        (self.seoable.books.blessed.first || self.seoable.books.first)
  end

  def find_paginated_listed_books_for_collection(params)
    return nil if self.seoable_type.nil? || self.seoable_type != 'Collection'
    
    method      = self.seoable.book_type.pluralize.to_sym # either calls the method 'books' or 'audiobooks'
    order_query = 'downloaded_count desc'

    if params[:sort]
      query_segments = params[:sort].split('_')
      field = query_segments[0..1].join('_')
      order_query = ([field] + [query_segments.last]).join(' ') # has to be in the most_downloaded asc format
    end

    # TODO: This calls a collection, so the best part to code this is the collection model  
    self.seoable.send(method).order(order_query).page(params[:page]).per(10)

  end

  def is_for_type?(type)
    self.seoable_type.downcase == type
  end

  def is_valid?
    return false if seoable.nil?
    self.is_for_type?('book') && self.format != 'online' ? self.seoable.available_in_format?(self.format) :  true
  end

end
