require 'rest_client'

namespace :test_web_api do
  
  task :register_book_review => :environment do
    data = {
        "user_fbconnect_id" => "1232134",
        "book_id" => 30,
        "action" => "register_book_review",
        "title" => "Awesome book",
        "content" => "I just can't put it down. Spent the last 2 weeks reading it, can't wait to finish and read the sequel.",
        "rating" => 5,
        "timestamp" => "Thu Feb 10 14:09:59 +0100 2011"
      }
    
      response = RestClient.post('http://localhost:3000/web_api', :json_data => data.to_json)
      puts "Response was: #{response.body}"
  end
  
  task :register_ios_user => :environment do
    data = {
        'action'                => 'register_ios_user',
        'user_fbconnect_id'     => '1232134',
        'user_email'            => 'test@test.com',
        'user_first_name'       => 'Zsolt',
        'user_last_name'        => 'Maslanyi',
        'user_location_city'    => 'Budapest',
        'user_location_country' => 'Hungary'
      }
      
      response = RestClient.post('http://localhost:3000/web_api', :json_data => data.to_json)
      puts "Response was: #{response.body}"
  end
  
  task :get_list_of_books_the_user_wrote_review_for => :environment do
    data = {
        'action'            => 'get_list_of_books_the_user_wrote_review_for',
        'user_fbconnect_id' => '1232134'
      }
      
      response = RestClient.post('http://localhost:3000/web_api/query', :json_data => data.to_json)
      puts "Response was: #{response.body}"
  end
  
  task :get_reviews_for_book => :environment do
    data = {
        'action'   => 'get_reviews_for_book',
        'book_id'  => 30,
        'page'     => 1,
        'per_page' => 20
      }
      
      response = RestClient.post('http://localhost:3000/web_api/query', :json_data => data.to_json)
      puts "Response was: #{response.body}"
  end
  
  task :get_classicly_url_for_book => :environment do
    data = {
        'action'  => 'get_classicly_url_for_book',
        'book_id' => 30
      }
      
      response = RestClient.post('http://localhost:3000/web_api/query', :json_data => data.to_json)
      puts "Response was: #{response.body}"
  end
  
  task :get_review_stats_for_book => :environment do
    data = {
        'action'  => 'get_review_stats_for_book',
        'book_id' => 30
      }
      
      response = RestClient.post('http://localhost:3000/web_api/query', :json_data => data.to_json)
      puts "Response was: #{response.body}"
  end
  
  task :get_review_for_book_by_user => :environment do
    data = {
        'action'  => 'get_review_for_book_by_user',
        'book_id' => 30,
        'user_fbconnect_id' => '1232134'
      }
      
      response = RestClient.post('http://localhost:3000/web_api/query', :json_data => data.to_json)
      puts "Response was: #{response.body}"
  end
  
  task :get_user_data => :environment do
    data = {
        'action'  => 'get_user_data',
        'user_fbconnect_id' => '1232134'
      }
      
      response = RestClient.post('http://localhost:3000/web_api/query', :json_data => data.to_json)
      puts "Response was: #{response.body}"
  end
end