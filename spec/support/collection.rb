Factory.define :collection do |f|
  f.book_type 'book'
  f.collection_type 'collection'
  f.name 'collection name'
  f.source "SELECT * FROM 'books' WHERE (author like '%collection name%')"
  f.source_type 'SQL'
  f.books { |books| [books.association(:book), books.association(:book)]  } # associates five books
end
