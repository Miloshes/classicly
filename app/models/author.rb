class Author < ActiveRecord::Base
  has_many :audiobooks
  has_many :books
  has_many :author_quotings
  # CLEANUP: rename to related_blog_posts, totally misleading
  has_many :blog_posts, :through => :author_quotings
  has_many :reviews, :as => :reviewable
  has_friendly_id :name, :use_slug => true
  
  # CLEANUP: could use instance variables to cache collection and audio_collection, and has_collection? methods could return !collection.blank?
  
  def audio_collection
    Collection.where(:name.matches => "%#{self.name}%", :book_type => 'audiobook').first
  end

  def collection
    Collection.where(:name.matches => "%#{self.name}%", :book_type => 'book').first
  end

  def featured_book(type='book')
    type.classify.constantize.where(:author_id => self.id).first
  end

  def get_paginated_books(parameters = {})
    order_query = 'downloaded_count desc'
    
    if parameters[:sort]
      query_segments  = parameters[:sort].split('_')
      field           = query_segments[0..1].join('_')
      order_query     = ([field] + [query_segments.last]).join(' ') # has to be in the most_downloaded asc format
    end
    
    return Book.for_author(self).order(order_query).page(parameters[:page]).per(10)
  end

  def has_audio_collection?
    Collection.exists?(['name LIKE ? AND book_type = ? ', "%#{self.name}%", 'audiobook'])
  end

  def has_collection?
    Collection.exists?(['name LIKE ? AND book_type = ? ', "%#{self.name}%", 'book'])
  end
end
