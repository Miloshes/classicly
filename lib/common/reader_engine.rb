class ReaderEngine
  BASE_BOOK_DIR = '/Users/zsoltmaslanyi/money/storage/latest_from_s3'
  
  attr_accessor :current_book_id, :current_book_content
  
  def initialize(params = {})
    params.stringify_keys!
    
    current_book_id = nil
    current_book_content = ''
    
    lazy_load_book_content(params['book_id']) if params['book_id']
  end
  
  # example params hash:
  # {
  #   "book_id" => 14,
  #   "render_data" => 
  #     [
  #       {"page" => 1, "first_character" => 0, "last_character" => 99, "first_line_indent" => true },
  #       {"page" => 2, "first_character" => 100, "last_character" => 199, "first_line_indent" => false }
  #     ]
  # }
  def handle_incoming_render_data(params)
    lazy_load_book_content(params['book_id'])
    
    params['render_data'].each do |record|
      Rails.logger.info "Page: #{record['page']}"
      Rails.logger.info "Characters: #{record['first_character']} - #{record['last_character']}"
      Rails.logger.info "Indent? #{record['first_line_indent'].to_s}"
    end
    
    return true
  end
  
  # NOTE: for now it works by loading the book from a local HD
  # Will only need support for loading books from S3 later
  def lazy_load_book_content(book_id)
    if book_id != self.current_book_id
      self.current_book_id = book_id
      self.current_book_content = open(BASE_BOOK_DIR + "/book_#{book_id}.txt").read
    end
  end
  
end