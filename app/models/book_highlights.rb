class BookHighlights < ActiveRecord::Base
  belongs_to :book
  
  validates :first_character, :presence => true
  validates :last_character, :presence => true
  validates :book, :presence => true
end
