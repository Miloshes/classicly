require 'zip/zip'
require 'tempfile'

class ReaderEngine
  BASE_BOOK_DIR = '/Users/zsoltmaslanyi/money/storage/latest_from_s3'
  
  attr_accessor :current_book_id
  attr_writer :current_book_content
  
  def initialize(params = {})
    params.stringify_keys!
    self.current_book_id = nil
    self.current_book_content = nil
  end

  def current_book_content
    @current_book_content
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
    
    converter = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    
    params['render_data'].each do |record|
      # fetch the book page
      book_page = book.book_pages.where(:page_number => record['page'].to_i).first()
      
      # get the page content
      page_content = self.current_book_content[record['first_character'].to_i..record['last_character'].to_i]
      
      # assemble new data hash
      new_data = {
        :first_character   => record['first_character'].to_i,
        :last_character    => record['last_character'].to_i,
        :first_line_indent => record['first_line_indent'],
        # fixing invalid UTF8 bytes in the meantime.
        # The extra space knocks out invalid bytes that are at the end of the string and can't be handled by iconv
        :content           => converter.iconv(page_content + ' ')[0..-2]
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

  def get_page book_id, page_number, library

    book = Book.find_by_id book_id
    return if book.nil?

    book_page = book.book_pages.find_by_page_number page_number
    return if book_page.nil?

    bookmarked = library.bookmark_exists? book, page_number

    return {
        :first_character   => book_page.first_character,
        :last_character    => book_page.last_character,
        :first_line_indent => book_page.first_line_indent,
        :content           => book_page.content,
        :total_page_count  => book.book_pages.count,
        :book_title        => book.pretty_title,
        :bookmarked        => bookmarked
    }.to_json

  end

  def get_book(book_id)
    lazy_load_book_content(book_id)
    current_book_content
  end

  private

  def lazy_load_book_content(book_id)
    if book_id != self.current_book_id
      self.current_book_id = book_id
      # for reading the book from S3, takes like 8 seconds so not advised
      # self.current_book_content = get_book_content_from_s3(book_id)
      # this is the quick solution, read it from the local disk
      self.current_book_content = open(BASE_BOOK_DIR + "/book_#{book_id}.txt").read
    end
  end

  def get_book_content_from_s3(book_id)
    book = Book.find book_id

    zip_file_data = book.file_data_for_format('txt.zip')
    # rubyzip cannot unzip strings in memory, so we have to create a temp file for it
    file = Tempfile.new('book_content.zip')
    file.write zip_file_data
    file.flush
    file.rewind
    data = ''
    Zip::ZipFile.foreach(file.path){ |f| data = f.get_input_stream.read}
    data
  ensure
    if file
      file.close
      file.unlink
    end
  end
  
end
