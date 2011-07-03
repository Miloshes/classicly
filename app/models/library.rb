class Library < ActiveRecord::Base  
  belongs_to :user, :class_name => 'Login', :foreign_key => 'login_id'
  
  has_many :books, :through => :library_books
  has_many :audiobooks, :through => :library_audiobooks
  
end
