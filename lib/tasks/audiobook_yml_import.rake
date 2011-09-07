# NOTE: These scripts are one-offs, they were used to import seed data into the DB, but it's good to keep them around.

class AudiobookMaintainerUtils
  
  def starting_letter_group_for(title)
    letters = ("a".."z").to_a
    numbers = ("0".."9").to_a
    
    first_letter = title.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s.first

    if numbers.include?(first_letter)
      result = 0
    elsif letters.include?(first_letter)
      result = letters.index(first_letter)+1
    else
      result = 27
    end
    
    return result
  end
  
end

# This was used at 2011.09.06. to do a general cleanup to the iOS databases
class RemoveUnnecessaryColumnsFromIosDbMigration < ActiveRecord::Migration
  
  def self.up
    ActiveRecord::Base.establish_connection :ios_audiobook_db

    Audiobook.reset_column_information
    
    remove_column :audiobooks, :classicly_download_url
    remove_column :audiobooks, :last_opened
    remove_column :audiobooks, :downloads_count
    
    drop_table :download_statuses
    
    ActiveRecord::Base.establish_connection :ios_book_db

    Book.reset_column_information
    
    remove_column :books, :license
    remove_column :books, :last_opened
  end
  
  def self.down
  end
  
end

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
  
  task :import_new_audiobooks_for_ios => :environment do
    # - copy the new Audiobooks (from:scraping to:ios) (DONE)
    #   - fill up starting letter groups (DONE)
    # - copy the new AudiobookChapters (from:scraping to:ios) (DONE)
    # - copy the new Narrators (from:scraping to:ios) (DONE)
    # - copy the new Authors (from:scraping to:ios) (DONE)
    # - update the filesizes (from:yml to:ios)
    # - re-run the the book-audiobook matcher
    
    # == Re-define models to avoid the complicated business logic, we're just copying records here
    
    class BasicAudiobook < ActiveRecord::Base
      set_table_name "audiobooks"
    end

    class BasicAudiobookChapter < ActiveRecord::Base
      set_table_name "audiobook_chapters"
    end
    
    class BasicAudiobookNarrator < ActiveRecord::Base
      set_table_name "audiobook_narrators"
    end
    
    class BasicAuthor < ActiveRecord::Base
      set_table_name "authors"
    end
    
    # == copy the new Audiobooks (from:scraping to:ios)
    
    ActiveRecord::Base.establish_connection :scrape_db
    
    first_id_to_import = 2948
    last_id_to_import  = Audiobook.last.id
    
    audiobooks_to_import = BasicAudiobook.where(:id.gt => first_id_to_import).order("id ASC").all()
    authors = Author.all()
    tmp = authors.first.name + " " # hack to invoke the query, we're switching DBs
    utils = AudiobookMaintainerUtils.new
    
    ActiveRecord::Base.establish_connection :development
    
    audiobooks_to_import.each do |source_audiobook|
      attributes = source_audiobook.attributes.select { |key, value| !value.blank? }
      
      author_id = attributes.delete("author_id")
      attributes["author"] = authors.select { |author| author.id == author_id }.first.name
      
      attributes.delete("featured")
      attributes.delete("librivox_link")
      
      attributes["starting_letter_group"] = utils.starting_letter_group_for(attributes["title"])
      
      new_audiobook = BasicAudiobook.find_by_id(source_audiobook.id)
      
      if new_audiobook.blank?
        new_audiobook    = BasicAudiobook.new(attributes)
        new_audiobook.id = source_audiobook.id
        new_audiobook.save
      else
        attributes.delete("id")
        new_audiobook.update_attributes(attributes)
      end
      
    end
    
    # == copy the new AudiobookChapters (from:scraping to:ios)
    
    ActiveRecord::Base.establish_connection :scrape_db
    
    first_id_to_import = 59753
    last_id_to_import  = AudiobookChapter.last.id
    chapters_to_import = AudiobookChapter.where(:id.gt => first_id_to_import).order("id ASC").all()
    
    ActiveRecord::Base.establish_connection :development
    
    BasicAudiobookChapter.reset_column_information
    
    chapters_to_import.each do |source_chapter|
      attributes  = source_chapter.attributes.select { |key, value| !value.blank? }
      new_chapter = BasicAudiobookChapter.find_by_id(source_chapter.id)
      
      attributes.delete("download_status")
      
      if new_chapter.blank?
        new_chapter    = BasicAudiobookChapter.new(attributes)
        new_chapter.id = source_chapter.id
    
        new_chapter.save
      else
        attributes.delete("id")
        new_chapter.update_attributes(attributes)
      end
    end
    
    # == copy the new Narrators (from:scraping to:ios)
    
    ActiveRecord::Base.establish_connection :scrape_db
    
    first_id_to_import  = 3681
    last_id_to_import   = BasicAudiobookNarrator.last.id
    narrators_to_import = BasicAudiobookNarrator.where(:id.gt => first_id_to_import).order("id ASC").all()
    
    ActiveRecord::Base.establish_connection :development
    
    BasicAudiobookNarrator.reset_column_information
    
    narrators_to_import.each do |source_narrator|
      attributes   = source_narrator.attributes.select { |key, value| !value.blank? }
      new_narrator = BasicAudiobookNarrator.find_by_id(source_narrator.id)
      
      if new_narrator.blank?
        new_narrator    = BasicAudiobookNarrator.new(attributes)
        new_narrator.id = source_narrator.id
    
        new_narrator.save
      else
        attributes.delete("id")
        new_narrator.update_attributes(attributes)
      end
    end
    
    # == copy the new Authors (from:scraping to:ios)
    
    ActiveRecord::Base.establish_connection :scrape_db
    
    first_id_to_import  = 9113
    last_id_to_import   = BasicAuthor.last.id
    authors_to_import   = BasicAuthor.where(:id.gt => first_id_to_import).order("id ASC").all()
    
    ActiveRecord::Base.establish_connection :development
    
    BasicAuthor.reset_column_information
    
    authors_to_import.each do |source_author|
      attributes = source_author.attributes.select { |key, value| !value.blank? }
      new_author = BasicAuthor.find_by_id(source_author.id)
      
      if new_author.blank?
        new_author    = BasicAuthor.new(attributes)
        new_author.id = source_author.id
    
        new_author.save
      else
        attributes.delete("id")
        new_author.update_attributes(attributes)
      end
    end
    
    # == update the filesizes (from:yml to:ios)
    
    data = YAML.load_file("db/yaml_exports/chapter_filesizes.yml")
    
    ActiveRecord::Base.establish_connection :ios_audiobook_db
    
    data.each_pair do |chapter_id, filesize|
      chapter = BasicAudiobookChapter.find(chapter_id)
      chapter.update_attributes(:filesize => filesize)
    end
    
  end
  
  task :remove_unnecessary_columns_from_ios_db => :environment do
    RemoveUnnecessaryColumnsFromIosDbMigration.down
  end
  
end