class Library < ActiveRecord::Base  
  belongs_to :user, :class_name => 'Login', :foreign_key => 'login_id'
  
  has_many :library_books, :dependent => :destroy
  has_many :books, :through => :library_books
  
  has_many :library_audiobooks, :dependent => :destroy
  has_many :audiobooks, :through => :library_audiobooks
  
  has_one :last_read_book, :through => :library_books, :order => 'library_books.last_opened DESC', :source => :book
  
  def self.clean_up_not_claimed_libraries
    self.where(:unregistered => true, :last_accessed.lt => Time.now - 2.days).destroy_all
  end
  
  def add_book(new_book)
    unless self.books.include?(new_book)
      self.books << new_book
      self.save
    end

    self.update_attributes(
      :books_downloaded => self.books.size,
      :last_accessed    => Time.now
    )
  end
  
  def register_for(owner)
    self.user         = owner
    self.unregistered = false
    self.save
  end

  def bookmark_exists?(book, page_number)
    return false if self.library_books.empty? || !self.books.include?(book)
    self.fetch_record_for_book(book).is_bookmarked_at? page_number
  end

  def fetch_record_for_book(book)
    return self.library_books.where(:book => book).first
  end

end
