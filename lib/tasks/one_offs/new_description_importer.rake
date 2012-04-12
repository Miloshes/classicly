# Notes: We got new descriptions done by Tyler in 2012. The "do_export" task reads in the source text file
# matches the descriptions to books and does a yaml export.
# The "import_to_ios_db" task puts them into the iOS DBs.

require "iconv"
require "rest_client"

namespace :new_description_importer do
  
  # Reads in the description from a text file, parses the data and handles the exceptions. Puts the result into a YAML file.
  task :do_export => :environment do

    new_record_starts = false
    author      = nil
    title       = nil
    description = nil

    ActiveRecord::Base.establish_connection :ios_book_db

    class Book < ActiveRecord::Base
    end

    missed_books = 0

    exceptions = {
      "Adventures of Daniel Boone, The" => [224, 225],
      "Autobiography of John Stuart Mill" => [1425],
      "Raven, The" => [17468],
      "Round the World" => [18244],
      "Daniel Deronda" => [4517],
      "Portrait of a Lady" => [16668, 1881],
      "Democracy in America" => [4865, 4866]
    }

    result = {}
    
    File.open("db/new_descriptions.txt").each_line do |line|

      if line.start_with? "=="
        new_record_starts = true

        if !title.blank?

          if title.start_with? "The "
            title = title[4..-1] + ", The"
          elsif title.start_with? "A "
            title = title[2..-1] + ", A"
          end

          search_options = {:title => title}

          if exceptions[title]
            books = Book.find(exceptions[title])
          else
            books = Book.where(search_options).all
          end

          if !books.blank?
            books.each do |book|
              # puts " - book: #{book.title} by #{book.author} (#{book.id})"
              result[book.id] = description.strip
            end
          else
            puts "!! NO BOOK"
            missed_books += 1
          end
        end

        title, author = line.split("||")
        title.sub!("==", "")

        description = ""
      else
        description += line
      end
    end # end of file parsing

    file_path = "db/yaml_exports/new_descriptions_2012_april.yaml"
    file = File.open(file_path, "wb")
    file.write(result.to_yaml)
    file.close

    puts "Done. Check out #{file_path} for the results!"

    puts "Problem!! Number of books that failed the export: #{missed_books}" if missed_books > 0
  end

  # Imports the descriptions from the exported YAML file into the iOS DB.
  task :import_to_ios_db => :environment do
    file_path        = "db/yaml_exports/new_descriptions_2012_april.yaml"
    description_data = YAML.load_file(file_path)    
    converter        = Iconv.new('UTF-8//IGNORE', 'UTF-8')

    ActiveRecord::Base.establish_connection :ios_book_db

    class Book < ActiveRecord::Base
    end

    description_data.each do |book_id, description|
      book = Book.find book_id
      book.update_attributes(:description => converter.iconv(description))      
    end

    puts "Done!. Updated #{description_data.size} book descriptions."
  end

  # Pushes the new descriptions to classicly.com via calling it's Web service
  task :push_to_classicly => :environment do
    file_path        = "db/yaml_exports/new_descriptions_2012_april.yaml"
    description_data = YAML.load_file(file_path)    
    converter        = Iconv.new('UTF-8//IGNORE', 'UTF-8')

    description_data.each do |book_id, description|
      data = {
        "book_id"     => book_id,
        "action"      => "update_book_description",
        "description" => converter.iconv(description)
      }
    
      response = RestClient.post('https://secure.classicly.com/web_api', :json_data => data.to_json)
    end

    puts "Done!"
  end

end