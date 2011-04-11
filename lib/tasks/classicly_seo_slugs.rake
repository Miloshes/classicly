desc 'Generate seo slugs for collectiosn. This seo slugs will be used in the path http://server/[:id]'

namespace :collections_seo_slugs do
  task :generate => :environment do
    Collection.find_each do|collection|
      collection.generate_seo_slugs
      puts "Generating seo slugs for collection (#{collection.id}): #{collection.name}"
    end
  end
end

namespace :books_seo_slugs do
  task :generate => :environment do
    Book.find_each do|book|
      book.generate_seo_slugs unless book.id == 4815
      puts "Generating seo slugs for book (#{book.id}): #{book.pretty_title}"
    end
  end
  #book id 4815 overflows the string limit!
end

namespace :audio_books_seo_slugs do
  task :generate => :environment do
    Audiobook.find_each do|audio_book|
      audio_book.generate_seo_slugs
      puts "Generating seo slugs for audio_book (#{audio_book.id}): #{audio_book.pretty_title}"
    end
  end
end