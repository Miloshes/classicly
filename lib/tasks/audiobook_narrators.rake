namespace :audiobook_narrators do
  
  task :import_audiobook_narrators_from_yaml_file => :environment do
    narrators = YAML.load_file("db/yaml_exports/audiobook_narrators.yml")
    
    narrators.each do |narrator_obj|
      new_narrator = AudiobookNarrator.create(:name => narrator_obj.name)
    end
    
    puts 'Done.'
  end
  
end