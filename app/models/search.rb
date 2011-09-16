# CLEANUP: add some documentation, input / output description
class Search
  
  def self.json_for_autocomplete(docids)
    documents = docids.collect {|docid| docid.split('_')}
    objects = []
    documents.each do|doc|
      objects << autocomplete_hash(doc)
    end
    objects
  end
  
  def self.autocomplete_hash(doc)
    case doc.first # checks the type of the doc [ab: audiobook, b: book, c: collection]
    when 'ab'
      audiobook = Audiobook.where(:id => doc.last).select('pretty_title, cached_slug, author_id').first
      slug = audiobook.author_book_slug
      return {:type => 'audiobook', :pretty_title => audiobook.pretty_title, :slug => slug }
    when 'b'
      book = Book.where(:id => doc.last).select('pretty_title, cached_slug, author_id').first
      slug = book.author_book_slug
      return {:type => 'book', :pretty_title => book.pretty_title, :slug => slug }
    when 'c'
      collection = Collection.where(:id => doc.last).select('name, cached_slug').first
      return {:type => 'collection', :name => collection.name, :slug => collection.cached_slug }
    end
  end

  def self.search_books(search, indextank, page)
    indices = indextank.search "#{search} type:book ", :len => 50

    bookids = indices['results'].collect{ |index| index['docid'].split('_').last.to_i }
    bookids.compact!

    Book.search_in_ids(bookids).page(page).per(10)
  end

end
