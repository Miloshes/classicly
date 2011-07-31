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

  def bookmark_exists? book, page_number
    return false if self.library_books.empty? || !self.books.include?(book)
    library_book_for_book(book).is_bookmarked_at? page_number
  end

  def library_book_for_book book
    return self.library_books.where(:book => book).first
  end

end
