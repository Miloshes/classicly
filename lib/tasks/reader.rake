require 'firewatir'

class ReaderScriptUtils
  
  def self.wait_untiL_rendering_is_done(browser, timeout = 300)
    start_time = Time.now
    until (browser.div(:id, 'rendering_status').text == 'Rendering status: finished with the book.') do
      sleep 1
      if Time.now - start_time> timeout
        raise RuntimeError, "Timed out after #{timeout} seconds"
      end
    end
    
    return true
  end
  
end

namespace :reader do
  
  # renders the whole book collection
  task :render_collection => :environment do
    
  end
  
  # renders a single book
  task :render_book => :environment do    
    book_id = ENV['book_id'] ? ENV['book_id'].to_i : nil
    
    if book_id.blank?
      puts "This script requires a book_id parameter to render that book."
      puts "rake reader:render_book book_id=6061"
      exit
    end
    
    browser = Watir::Browser.new
    browser.goto("http://localhost:3000/render_books_to_reader?id=#{book_id}")
    ReaderScriptUtils.wait_untiL_rendering_is_done(browser)
  end
  
end