class Library < ActiveRecord::Base  
  belongs_to :user, :class_name => 'Login', :foreign_key => 'login_id'
  
  has_many :library_books
  has_many :books, :through => :library_books
  
  has_many :library_audiobooks
  has_many :audiobooks, :through => :library_audiobooks
  
  has_one :last_read_book, :through => :library_books, :order => 'library_books.last_opened DESC', :source => :book
end
