require 'rest_client'

namespace :test_incoming_data do
  
  # == Book review creation
  
  task :create_book_review => :environment do
    data = {
        "user_fbconnect_id" => "1232134",
        "book_id" => 15,
        "action" => "create_book_review",
        "title" => "Awesome book",
        "content" => "I just can't put it down. Spent the last 2 weeks reading it, can't wait to finish and read the sequel.",
        "rating" => 5,
        "timestamp" => "Thu Feb 10 14:09:59 +0100 2011"
      }
    
      response = RestClient.post('http://localhost:3000/incoming_data', :json_data => data.to_json)
      puts "Response was: #{response.body}"
  end
end