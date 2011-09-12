# CLEANUP: might need to rename if we rename the model
# Generate seo slugs for collections. This seo slugs will be used in the path http://server/[:id]

namespace :collections_seo_slugs do
  
  task :generate => :environment do
    # first things first, drop all collection's slugs:
    SeoSlug.where(:seoable_type => 'Collection').delete_all
    
    Collection.find_each do |collection|
      collection.generate_seo_slugs
      puts "Generating seo slugs for collection (#{collection.id}): #{collection.name}"
    end
  end
  
end

namespace :books_seo_slugs do
  
  task :generate => :environment do
    # drop all book's slugs:
    SeoSlug.where(:seoable_type => 'Book').delete_all
    # create slugs:
    Book.find_each do |book|
      book.generate_seo_slugs(['pdf', 'kindle'])
      puts "Generating seo slugs for book (#{book.id}): #{book.pretty_title}"
    end
  end
  
  task :generate_online_format => :environment do
    SeoSlug.where(:seoable_type => 'Book', :format => 'online').delete_all
    Book.find_each do|book|
      book.generate_seo_slugs(['online'])
      puts "read online seo slug for:  (#{book.id}): #{book.pretty_title}"
    end
  end
  
end

namespace :audiobooks_seo_slugs do
  
  task :generate => :environment do
    format = 'mp3'
    
    SeoSlug.where(:format => format).delete_all
    
    Audiobook.find_each do |audio_book|
      audio_book.generate_seo_slugs([format])
      puts "Generating seo slugs for audio_book (#{audio_book.id}): #{audio_book.pretty_title}"
    end
  end
  
end