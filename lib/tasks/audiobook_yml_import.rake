# NOTE: These scripts are one-offs, they were used to import seed data into the DB, but it's good to keep them around.
namespace :audiobook_yml_import do
  
  task :import_audiobook_chapters => :environment do
    chapter_data = YAML.load_file("db/yaml_exports/audiobook_chapters.yml")
    
    chapter_data.each do |new_chapter_obj|
      new_chapter = AudiobookChapter.create(
          :audiobook_id          => new_chapter_obj.audiobook_id,
          :title                 => new_chapter_obj.title,
          :duration              => new_chapter_obj.duration,
          :download_link         => new_chapter_obj.download_link,
          :audiobook_narrator_id => new_chapter_obj.audiobook_narrator_id
        )
      
      puts " - done with ##{new_chapter.id}" if new_chapter.id % 1000 == 0
    end
  end
  
  task :import_audiobook_narrators => :environment do
    narrators = YAML.load_file("db/yaml_exports/audiobook_narrators.yml")
    
    narrators.each do |narrator_obj|
      new_narrator = AudiobookNarrator.create(:name => narrator_obj.name)
    end
    
    puts 'Done.'
  end
  
  task :import_audiobook_descriptions => :environment do
    description_data = YAML.load_file("db/yaml_exports/audiobook_descriptions.yml")
    
    description_data.each do |record|
      record.symbolize_keys!
      audiobook = Audiobook.find(record[:audiobook_id])
      audiobook.update_attributes(:description => record[:description])
      
      puts " - done with ##{audiobook.id}" if audiobook.id % 100 == 0
    end
  end
  
  task :import_librivox_zip_links => :environment do
    link_data = YAML.load_file("db/yaml_exports/librivox_zip_links.yml")
    
    link_data.each do |record|
      record.symbolize_keys!
      audiobook = Audiobook.find(record[:audiobook_id])
      audiobook.update_attributes(:librivox_zip_link => record[:zip_link])
      
      puts " - done with ##{audiobook.id}" if audiobook.id % 100 == 0
    end
  end
  
end