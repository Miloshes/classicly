# Creates new collections based on the genres.
# This script is obsolete now, but might need to re-run it at some-point.

desc 'creates new collections from existing genres'

task :create_collections_from_genres => :environment do
  ["Reference", "Non-fiction", "Post-1930", "Fiction", "Language", "Creative Commons", "Humor", "Satire", "Government Publication", 
    "Short Story", "Nautical", "Games", "Essays", "Computers", "Instructional", "Mystery / Detective", 
    "Cooking", "Criticism", "Science", "Religion", "Health", "Sexuality", "Nature", "Short Story Collection",
    "Pirate Tales", "Correspondence", "Myth", "Music", "Espionage", "Thriller", "Harvard Classics", "Women's Studies", "Periodical",
    "African-American Studies", "Art", "Gothic", "Etiquette"].each do |genre_name|
      genre = Genre.where(:name => genre_name).first
      collection = Collection.create(:name => genre.name, :collection_type => 'genre', :book_type => 'book', :source_type => 'DBCategory', :source => genre.id)
      puts "Assigning books from genre #{genre.id}- #{genre.name} to collection: #{collection.id}- #{collection.name}" 
      collection.books = genre.books
      collection.save
      SeoSlug.create(:seoable => collection, :slug => collection.cached_slug, :format => "all")
    end
    
end