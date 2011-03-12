desc 'Update author collections. Books with author, which are not included in this authors collection should be included'
task :update_author_collections => :environment do
  @collections = Collection.all(:conditions => ["book_type = 'book' and  collection_type ='author'"])
   @collections.each do |collection|
    puts "Updating #{collection.name}\'s collection"
    @book_ids = Book.joins(:author).where(:author => {:cached_slug => collection.cached_slug}).select("books.id")
    @book_ids.each do |book_id|
      book = Book.find(book_id)
      unless book.collections.include?(collection)
        puts "Book #{book.title} is being assigned to  #{collection.name}\'s collection"
        book.collections << collection
        book.save
      end
    end
  end
end
