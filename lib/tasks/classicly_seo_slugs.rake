desc 'Generate seo slugs for collectiosn. This seo slugs will be used in the path http://server/[:id]'

namespace :collections_seo_slugs do
  task :generate => :environment do
    #drop all collection seos
    SeoSlug.where(:seoable_type => 'Collection').delete_all
    Collection.find_each do|collection|
      collection.generate_seo_slugs
      puts "Generating seo slugs for collection (#{collection.id}): #{collection.name}"
    end
  end
end

namespace :books_seo_slugs do
  task :generate => :environment do
    SeoSlug.where(:seoable_type => 'Book').delete_all
    Book.find_each do|book|
      book.generate_seo_slugs(['pdf', 'kindle', 'online'])
      puts "Generating seo slugs for book (#{book.id}): #{book.pretty_title}"
    end
  end
  task :generate_online_format => :environment do
    SeoSlug.where(:format => 'online').delete_all
    Book.find_each do|book|
      book.generate_seo_slugs(['online'])
      puts "read online seo slug for:  (#{book.id}): #{book.pretty_title}"
    end
  end
end

namespace :audio_books_seo_slugs do
  task :generate => :environment do
    format = 'mp3'
    SeoSlug.where(:format => format).delete_all
    Audiobook.find_each do|audio_book|
      audio_book.generate_seo_slugs([format])
      puts "Generating seo slugs for audio_book (#{audio_book.id}): #{audio_book.pretty_title}"
    end
  end
end