require 'firewatir' if Rails.env.development?

class ReaderScriptUtils
  
  def self.start_rendering_and_wait_untiL_its_done(browser, timeout = 1200)
    # start the rendering
    browser.button(:id => 'render_book').click
    
    # check for finish message, along with timeout
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
    puts "WARNING: remember to nuke all the book pages from the DB before running this!"
    # books that are done 0..444
    start_id = 444
    # end_id = Book.order('id DESC').limit(1).first().id

    top1000_books = YAML.load_file(APP_CONFIG['yaml_exports_path'] + '/top1000_books.yml').sort
    
    # start_id.upto(end_id) do |book_id|
    top1000_books.each do |book_id|
      next if book_id <= 444
      
      browser = Watir::Browser.new
      browser.goto("http://localhost:3000/render_book_for_the_reader/#{book_id}")
      finished = ReaderScriptUtils.start_rendering_and_wait_untiL_its_done(browser)
      
      if finished
        puts " - done with book: #{book_id}"
        puts "Time: #{Time.now.to_s(:db)}" if book_id % 100 == 0
      else
        puts " ERROR: #{book_id}"
      end
      
      browser.close
    end
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
    browser.goto("http://localhost:3000/render_book_for_the_reader/#{book_id}")
    ReaderScriptUtils.start_rendering_and_wait_untiL_its_done(browser)
  end
  
  task :test => :environment do
    book_id = 6
    
    base_dir = '/Users/zsoltmaslanyi/money/storage/latest_from_s3'
    str = open(base_dir + "/book_#{book_id}.txt").read
    
    puts str.inspect
  end
  
end