class BookPage < ActiveRecord::Base
  belongs_to :book
  
  validates :first_character, :presence => true
  validates :last_character, :presence => true
  validates :content, :presence => true
end
