class OnlineReader
  
  # Removes the "content" part of the book pages for the books that are not read to save DB space
  def self.update_cache
    Book.where(:global_last_opened.lt => Time.now - 2.weeks).all.each do |book|
      book.wipe_book_pages!
    end
  end
  
end