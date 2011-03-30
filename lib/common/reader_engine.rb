class ReaderEngine
  BASE_BOOK_DIR = '/Users/zsoltmaslanyi/money/storage/latest_from_s3'
  
  attr_accessor :current_book_id, :current_book_content
  
  def initialize(params = {})
    current_book_id = nil
    current_book_content = ''
    
    lazy_load_book_content(params[:book_id]) if params[:book_id]
  end
  
  # params should be:
  # book_id: 1
  # page: 15
  # start_character: 15000
  # end_character: 15500
  def handle_incoming_render_data(params)
    
  end
  
  def get_book_content_for_character_ranges(book_id, start_character, end_character)
    lazy_load_book_content(book_id)
    
    return current_book_content[start_character..end_character]
  end
  
  # NOTE: for now it works by loading the book from a local HD
  # Will only need support for loading
  def lazy_load_book_content(book_id)
    if book_id != self.current_book_id
      self.current_book_id = book_id
      self.current_book_content = open(BASE_BOOK_DIR + "/book_#{book_id}.txt").read
    end
  end
  
end