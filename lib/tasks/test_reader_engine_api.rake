require 'rest_client'

namespace :test_reader_engine_api do

  task :book_rendering => :environment do
    data = 
    {
      "action" => "render_book",
      "book_id" => 6061
    }
    
    response = RestClient.post('http://localhost:3000/reader_engine_api', :json_data => data.to_json)
    puts "Response was: #{response.body}"
  end

  task :render_data_processing => :environment do
    data = 
    {
      "action" => "process_render_data",
      "book_id" => 6061,
      "render_data" => 
        [
          {"page" => 1, "first_character" => 0, "last_character" => 2111, "first_line_indent" => true },
          {"page" => 2, "first_character" => 2120, "last_character" => 5602, "first_line_indent" => false },
          {"page" => 3, "first_character" => 5606, "last_character" => 8582, "first_line_indent" => true },
          {"page" => 4, "first_character" => 8592, "last_character" => 11178, "first_line_indent" => false },
          {"page" => 5, "first_character" => 11184, "last_character" => 14567, "first_line_indent" => true }
        ]
    }
    
    response = RestClient.post('http://localhost:3000/reader_engine_api', :json_data => data.to_json)
    puts "Response was: #{response.body}"
  end
  
  task :get_book => :environment do
    data = 
    {
      "action" => "get_book",
      "book_id" => 14
    }
    
    response = RestClient.post('http://localhost:3000/reader_engine_api/query', :json_data => data.to_json)
    puts "Response was: #{response.body}"
  end
  
  task :get_page => :environment do
    data = 
    {
      "action"      => "get_page",
      "book_id"     => 6061,
      "page_number" => 2
    }
    
    response = RestClient.post('http://localhost:3000/reader_engine_api/query', :json_data => data.to_json)
    puts "Response was: #{response.body}"
  end
  
end