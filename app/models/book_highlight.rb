class BookHighlight < ActiveRecord::Base
  belongs_to :book
  belongs_to :user, :class_name => 'Login', :foreign_key => 'login_id'
  
  validates :first_character, :presence => true
  validates :last_character, :presence => true
  validates :book, :presence => true
  
  # highlights are tied to registered users. Highlights from unregistered users are saved as AnonymousBookHighlight
  validates :user, :presence => true
  validates :fb_connect_id, :presence => true
end
