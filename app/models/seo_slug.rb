class SeoSlug < ActiveRecord::Base
  belongs_to :seoable, :polymorphic => true

  def find_featured_book_for_collection
    return nil if self.seoable_type.nil? || self.seoable_type != 'Collection'
    self.seoable.book_type == 'audiobook' ? (self.seoable.audiobooks.blessed.first || self.seoable.audiobooks.first) :
        (self.seoable.books.blessed.first || self.seoable.books.first)
  end

  def find_paginated_blessed_books_for_collection(params)
    return nil if self.seoable_type.nil? || self.seoable_type != 'Collection'
    self.seoable.book_type == 'audiobook' ? self.seoable.audiobooks.blessed.page(params[:page]).per(25) :
        self.seoable.books.blessed.page(params[:page]).per(25)
  end

  def find_paginated_listed_books_for_collection(params)
    return nil if self.seoable_type.nil? || self.seoable_type != 'Collection'
    self.seoable.book_type == 'audiobook' ? self.seoable.audiobooks.page(params[:page]).per(25) :
        self.seoable.books.page(params[:page]).per(25)
  end

  def download_format
    self.format == 'kindle' ? 'azw' : self.format
  end

  def is_for_audio_book?
    self.seoable_type == 'Audiobook'
  end

  def is_for_book?
    self.seoable_type == 'Book'  
  end

  def is_for_collection?
    self.seoable_type == 'Collection'
  end

  def is_valid?
    return false if seoable.nil?
    if self.is_for_book? && self.format != 'online'
      return seoable.available_in_format?(download_format)
    end
    true
  end
end
