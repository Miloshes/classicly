require 'iconv'

# WARNING: destructive migration!
# Drops the book_pages table, and re-builds it by importing the renderdata from a .yml file
class ImportRenderDataMigration < ActiveRecord::Migration
  
  def self.up
    drop_table :book_pages
    
    create_table :book_pages do |t|
      t.integer :book_id
      t.integer :page_number
      t.integer :first_character
      t.integer :last_character
      t.text :content
      t.boolean :first_line_indent, :default => false, :null => false
    end
    
    add_index :book_pages, [:book_id, :page_number], :unique => true, :name => 'book_id_page_number_index_for_book_pages'
    
    BookPage.reset_column_information
    
    File.open("db/yaml_exports/book_page_renderdata.yml") do |yf|
      YAML.load_documents(yf) do |record|
        record.symbolize_keys!

        book_page = BookPage.create(
          :book_id           => record[:book_id],
          :page_number       => record[:page_number],
          :first_character   => record[:first_character],
          :last_character    => record[:last_character],
          :first_line_indent => record[:first_line_indent]
        )

        puts " - done with ##{book_page.id}" if book_page.id % 10000 == 0
      end
    end
  end
  
end

namespace :data_maintenance do

  task :encode_audio_book_chapter_titles => :environment do
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    AudiobookChapter.find_each do |chapter|
      valid_string = ic.iconv(chapter.title + ' ')[0..-2]
      chapter.update_attribute :title, valid_string
      puts "encoding chapter: (#{chapter.id})#{chapter.title}"
    end
  end
  
  task :encode_audiobook_descriptions => :environment do
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    Audiobook.find_each do |abook|
      unless abook.description.nil?
        valid_string = ic.iconv(abook.description + ' ')[0..-2]
        abook.update_attribute :description, valid_string
        puts "encoding audiobook: (#{abook.id})"
      end
    end
  end

  task :update_collections_download_counts => :environment do
    Collection.update_cache_downloaded_count
  end

  task :generate_parsed_descriptions_for_collections => :environment do
    Collection.find_each do |collection|
      collection.set_parsed_description
      collection.save
      puts " - done with collection ##{collection.id}"
    end
  end
  
  task :set_is_rendered_for_online_reading_flag_for_books => :environment do
    Book.find_each do |book|
      book.update_attributes(:is_rendered_for_online_reading => book.book_pages.size > 0)
    end
  end
  
  # Imports the book page renderdata from a YAML file
  task :import_render_data => :environment do
    if ENV["confirm"] != 'yes'
      puts "WARNING: this script *NUKES* the whole book_pages table, and imports the renderdata from an .yml file afterwards."
      puts "If you know what you're doing: rake data_maintenance:import_render_data confirm=yes"
      exit
    end
    
    ImportRenderDataMigration.up
  end

end
