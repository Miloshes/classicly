require 'rest_client'

class ImportDownloadURLsMigration < ActiveRecord::Migration
  def self.up    
    add_column :books, :classicly_download_url, :text
    
    Book.reset_column_information 
    
    url_data = YAML.load_file("db/yaml_exports/download_urls.yml")
    
    Book.all.each do |book|
      book.update_attributes(:classicly_download_url => url_data[book.id])
    end
  end
end

# For storing scripts regarding SEO URLs
namespace :seo_urls do
  
  # Exports the current download URLs into a YAML file.
  # Needs to be called before certain scripts can run.
  # Scripts that use that:
  #   - import_download_urls_from_yaml_file_to_ios_db
  task :export_download_urls_to_yaml_file => :environment do
    include ActionDispatch::Routing::UrlFor
    include Rails.application.routes.url_helpers
    
    default_url_options[:host] = 'http://www.classicly.com'
    url_hash = {}
    
    puts "Script running..."
    
    Book.all.each do |book|
      url_hash[book.id] = book_download_page_url(book.author, book, 'pdf')
    end
    
    export_file = File.open("db/yaml_exports/download_urls.yaml", 'wb')
    export_file.write(url_hash.to_yaml)
    export_file.close
    
    puts "Done."
  end
  
  task :import_download_urls_from_yaml_file_to_ios_db => :environment do
    if Rails.env != 'library_db'
      puts "WARNING"
      puts "This script will import download URLs into the iOS client app's DB!"
      puts "To make sure you know what you're doing run this with RAILS_ENV=ios_db"
      exit
    end
    
    url_file_path = "db/yaml_exports/download_urls.yml"
    if !File.exists?(url_file_path)
      puts "This script requires #{url_file_path} to work."
      exit
    end
    
    puts "Script running..."
    
    ImportDownloadURLsMigration.up
    
    puts "Done."
  end
  
  # This task will push the download URLs for the books into the fb-library server apps DB.
  # It does that by sending the update parameters to an URL with a PUT request.
  task :push_download_urls_to_library_app => :environment do
    include ActionDispatch::Routing::UrlFor
    include Rails.application.routes.url_helpers
    
    default_url_options[:host] = 'http://www.classicly.com'
    
    errors_while_pushing = false
    
    Book.all.each do |book|
      url_to_call = "http://fb-library.heroku.com/books/#{book.id}/update_classicly_download_url"    
      response = RestClient.put url_to_call, :download_url => book_download_page_url(book.author, book, 'pdf')
      
      if response.body != 'SUCCESS'
        errors_while_pushing = true
        break
      end
    end
    
    if errors_while_pushing
      puts 'There were errors while pushing the download URLs to the server.'
    else
      puts 'Done.'
    end
  end
  
end