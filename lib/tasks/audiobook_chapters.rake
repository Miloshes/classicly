namespace :audiobook_chapters do
  
  task :import_audiobook_chapters_from_yaml_file => :environment do
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
  
end