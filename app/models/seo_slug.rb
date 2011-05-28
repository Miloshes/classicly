class SeoSlug < ActiveRecord::Base
  belongs_to :seoable, :polymorphic => true
  scope :kindle, where(:format => 'kindle')
  scope :mp3, where(:format => 'mp3')
  scope :pdf, where(:format => 'pdf')
  scope :read_online, where(:format => 'online')

  def find_featured_book_for_collection
    return nil if self.seoable_type.nil? || self.seoable_type != 'Collection'
    self.seoable.book_type == 'audiobook' ? (self.seoable.audiobooks.blessed.first || self.seoable.audiobooks.first) :
        (self.seoable.books.blessed.first || self.seoable.books.first)
  end

  def find_paginated_blessed_books_for_collection(params)
    return nil if self.seoable_type.nil? || self.seoable_type != 'Collection'
    self.seoable.book_type == 'audiobook' ? self.seoable.audiobooks.blessed.page(params[:page]).per(10) :
        self.seoable.books.blessed.page(params[:page]).per(10)
  end

  def find_paginated_listed_books_for_collection(params)
    return nil if self.seoable_type.nil? || self.seoable_type != 'Collection'
    self.seoable.book_type == 'audiobook' ? self.seoable.audiobooks.page(params[:page]).per(10) :
        self.seoable.books.page(params[:page]).per(10)
  end

  def download_format
    self.format == 'kindle' ? 'azw' : self.format
  end

  def is_for_type?(type)
    self.seoable_type.downcase == type
  end
  
  def is_valid?
    return false if seoable.nil?
    if self.is_for_type?('book') && self.format != 'online'
      return seoable.available_in_format?(download_format)
    end
    true
  end
end
