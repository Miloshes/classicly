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
    # switch current book if necessary
    lazy_load_book_content(params['book_id'])
    
    # fetch the book model
    book = Book.find(params['book_id'].to_i)
    
    params['render_data'].each do |record|
      # fetch the book page
      book_page = book.book_pages.where(:page_number => record['page'].to_i).first()
      
      # assemble new data hash
      new_data = {
        :first_character   => record['first_character'].to_i,
        :last_character    => record['last_character'].to_i,
        :first_line_indent => record['first_line_indent'],
        :content           => self.current_book_content[record['first_character'].to_i..record['last_character'].to_i]
      }
      
      # update attributes
      if book_page
        book_page.update_attributes(new_data)
      else
        # or create a new object in the DB
        book.book_pages.create(new_data.merge(:page_number => record['page'].to_i))
      end
    end
    
    return true
  end
  
  def get_page(book_id, page_number)
    lazy_load_book_content(book_id)
    

    book = Book.find(book_id)
    return nil if book.blank?
    
    book_page = book.book_pages.where(:page_number => page_number).first()
    return nil if book_page.blank?
    
    return {
        :first_character   => book_page.first_character,
        :last_character    => book_page.last_character,
        :first_line_indent => book_page.first_line_indent,
        :content           => book_page.content,
        :total_page_count  => book.book_pages.count,
        :book_title        => book.pretty_title
      }.to_json
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