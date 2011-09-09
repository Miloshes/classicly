class LibraryBook < ActiveRecord::Base
  belongs_to :book
  belongs_to :library
  has_many :bookmarks

  def is_bookmarked_at?(page_number)
    self.bookmarks.exists? :page_number => page_number
  end

end
