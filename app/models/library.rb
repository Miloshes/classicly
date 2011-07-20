class Library < ActiveRecord::Base  
  belongs_to :user, :class_name => 'Login', :foreign_key => 'login_id'
  
  has_many :library_books, :dependent => :destroy
  has_many :books, :through => :library_books
  
  has_many :library_audiobooks, :dependent => :destroy
  has_many :audiobooks, :through => :library_audiobooks
  
  has_one :last_read_book, :through => :library_books, :order => 'library_books.last_opened DESC', :source => :book
  
  def self.clean_up_not_claimed_libraries
    self.where(:unregistered => true, :last_accessed.lt => Time.now - 2.days).delete_all
  end
  
end
