FactoryGirl.define do
  
  factory :collection do
    book_type "book"
    collection_type "collection"
    name "collection name"
    source "SELECT * FROM 'books' WHERE (author like '%collection name%')"
    source_type "SQL"

    books { |books| [books.association(:book), books.association(:book)] }
  end
  
end
