require "iconv"

namespace :ol_import_test do

  task :look_for_keys => :environment do
    base_dir = "/Users/zsoltmaslanyi/money/the_big_migration"
    filename = "source_sample.txt"
    
    file = File.open(base_dir + "/" + filename)
    
    counter = 0
    
    file.each_line do |line|
      
    end
    
    file.close
  end
  
  
  # Creates a ~70megs source sample file from the 40gig one. Easier to work with it.
  task :create_source_sample => :environment do
    puts "Creating a smaller sample file from the huge original one."
    base_dir = "/Users/zsoltmaslanyi/money/the_big_migration"
    filename = "ol_dump_2011-08-31.txt"
    
    source_file = File.open(base_dir + "/" + filename)
    target_file = File.open(base_dir + "/" + "source_sample.txt", "wb")
    
    counter = 0
    
    source_file.each_line do |line|
      target_file.write(line) if counter % 500 == 0
      counter += 1
    end
    
    source_file.close
    target_file.close
    
    puts "Done."
  end
  
  task :run => :environment do
    base_dir  = "/Users/zsoltmaslanyi/money/the_big_migration"
    filename  = "ol_dump_authors_2011-08-31.txt"
    converter = Iconv.new("UTF-8//IGNORE", "UTF-8")
    
    source_file = File.open(base_dir + "/" + filename)
    
    counter = 0
    
    # type_key = json_data["type"]["key"]
    
    all_keys = []
    
    attributes_that_matter = ["name", "personal_name", "title", "death_date", "birth_date", "date", "bio", "key", "website", "wikipedia", "location"]
    
    source_file.each_line do |line|
      data = line.split("\t")
      json_data = ActiveSupport::JSON.decode(data.last)
      
      next if json_data["type"]["key"] != "/type/author"
      # only keep the latest revision, if that information is available
      next if json_data["latest_revision"] && json_data["latest_revision"] != json_data["revision"]
      
      # copy over the attributes that matter
      filtered_data = {}
      
      json_data.each_pair do |attribute, value|
        next unless attributes_that_matter.include?(attribute)
        
        filtered_data[attribute] = value
      end
      
      # == attribute transformations
      
      filtered_data["openlibrary_key"] = filtered_data.delete("key")
      
      # We're filtering out date's that are erronous strings. They should contain at least one number
      filtered_data.delete("date") if filtered_data["date"] && !(filtered_data["date"] =~ /\d/)
      
      # "bio" is actually a hash with "type" and "value" keys
      filtered_data["bio"] = filtered_data.delete("bio")["value"] if filtered_data["bio"]
      
      # personal name is useful, but sometimes it's just the duplication of name
      filtered_data["personal_name"] if filtered_data["personal_name"] == filtered_data["name"]
      
      # TODO: website and wikipedia should be added into the links array with "website" and "wikipedia" as keys
      
      # json_data.each_key do |k|
      #   all_keys << k unless all_keys.include?(k)
      # end
      
      # interested = ["identifiers", "isbn_13", "isbn_10", "works", "     _date", "body", "website_name"]
      # 
      # show = false
      # interested.each do |field|
      #   show = true if json_data[field]
      # end
      # 
      # puts "#{json_data.inspect}\n\n" if show
       
      # counter += 1
      # 
      # break if counter == 1500000
      
      puts filtered_data.inspect
    end
    
    source_file.close
  end
  
end
