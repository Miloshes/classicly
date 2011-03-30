require 'rest_client'

namespace :test_reader_engine_api do
  
  task :book_rendering => :environment do
    data = 
    {
      "action" => "process_render_data",
      "book_id" => 14,
      "render_data" => 
        [
          {"page" => 1, "first_character" => 0, "last_character" => 99, "first_line_indent" => true },
          {"page" => 2, "first_character" => 100, "last_character" => 199, "first_line_indent" => false },
          {"page" => 3, "first_character" => 200, "last_character" => 299, "first_line_indent" => true },
          {"page" => 4, "first_character" => 300, "last_character" => 399, "first_line_indent" => false },
          {"page" => 5, "first_character" => 400, "last_character" => 499, "first_line_indent" => true }
        ]
    }
    
    response = RestClient.post('http://localhost:3000/reader_engine_api', :json_data => data.to_json)
    puts "Response was: #{response.body}"
  end
  
  task :get_book_content => :environment do
    data = 
    {
      "action" => "get_book_content",
      "book_id" => 14
    }
    
    response = RestClient.post('http://localhost:3000/reader_engine_api/query', :json_data => data.to_json)
    puts "Response was: #{response.body}"
  end
  
end