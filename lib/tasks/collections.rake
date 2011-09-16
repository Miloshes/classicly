desc 'rake tasks for collection model'
namespace :collections do
  task :associate_audio_collections => :environment do
    Collection.find_each(:conditions => "book_type = 'book'") do|collection|
      audio_collection = Collection.find_by_name_and_book_type(collection.name, 'audiobook')
      unless audio_collection.nil?
        collection.audio_collection = audio_collection
        collection.save
        puts "Assignig audio collection to collection: #{collection.name}"
      end
    end
  end
end