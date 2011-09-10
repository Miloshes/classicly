class BookPage < ActiveRecord::Base
  belongs_to :book
  
  validates :book, :presence => true
  validates :first_character, :presence => true
  validates :last_character, :presence => true
  validates :page_number, :presence => true
  
  def render_page_content_from(book_content)
    # if the book is rendered, we shouldn't do anything
    return if self.book.is_rendered_for_online_reading?
    
    converter = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    
    # getting the page content from the character ranges
    page_content_var = book_content[ self.first_character .. self.last_character ]
    
    # applying the UTF8 character fix trick
    page_content_var = converter.iconv(page_content_var + ' ')[0..-2]
    
    self.update_attributes(:content => page_content_var)
  end
  
  # Destructive method. Deletes the "content" attribute to save space in the DB.
  # The content can be re-rendered anytime based on the first and last character data.
  def wipe_page_content!
    self.update_attributes(:content => nil)
  end
  
end
