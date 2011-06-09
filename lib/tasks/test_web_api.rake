require 'rest_client'

namespace :test_web_api do
  
  task :register_book_review => :environment do
    data = {
        "user_fbconnect_id" => "1232134",
        "device_id" => "ASDASD",
        "book_id" => 30,
        "action" => "register_book_review",
        "content" => "I just can't put it down. Spent the last 2 weeks reading it, can't wait to finish and read the sequel.2",
        "rating" => 5,
        "timestamp" => "Thu Feb 10 15:09:59 +0100 2011"
      }
    
      response = RestClient.post('http://localhost:3000/web_api', :json_data => data.to_json)
      puts "Response was: #{response.body}"
  end
  
  task :register_anonymous_book_review => :environment do
    data = {
        'device_id' => 'ASDASD',
        "book_id"   => 32,
        "action"    => "register_book_review",
        "content"   => "I just can't put it down. Spent the last 2 weeks reading it, can't wait to finish and read the sequel.",
        "rating"    => 5,
        "timestamp" => "Thu Feb 10 15:09:59 +0100 2011"
      }
    
      response = RestClient.post('http://localhost:3000/web_api', :json_data => data.to_json)
      puts "Response was: #{response.body}"
  end
  
  task :register_audiobook_review => :environment do
    data = {
        "user_fbconnect_id" => "1232134",
        "audiobook_id" => 12,
        "action" => "register_book_review",
        "content" => "I just can't put it down. Spent the last 2 weeks reading it, can't wait to finish and read the sequel.",
        "rating" => 5,
        "timestamp" => "Thu Feb 10 15:09:59 +0100 2011"
      }
    
      response = RestClient.post('http://localhost:3000/web_api', :json_data => data.to_json)
      puts "Response was: #{response.body}"
  end
  
  task :register_ios_user => :environment do
    data = {
        'structure_version'     => '1.2',
        'action'                => 'register_ios_user',
        'user_fbconnect_id'     => '1232134',
        'device_id'             => 'ASDASD',
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
        'user_fbconnect_id' => '1232134',
        'structure_version' => '1.1'
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
      puts "Response for BOOK was: #{response.body}"
      
      data = {
          'action'        => 'get_reviews_for_book',
          'audiobbook_id' => 30,
          'page'          => 1,
          'per_page'      => 20
        }

        response = RestClient.post('http://localhost:3000/web_api/query', :json_data => data.to_json)
        puts "Response for AUDIOBOOK was: #{response.body}"
  end
  
  task :get_classicly_url_for_book => :environment do
    data = {
        'action'  => 'get_classicly_url_for_book',
        'book_id' => 30
      }
      
      response = RestClient.post('http://localhost:3000/web_api/query', :json_data => data.to_json)
      puts "Response for BOOK was: #{response.body}"

      data = {
          'action'  => 'get_classicly_url_for_book',
          'audiobook_id' => 10
        }

      response = RestClient.post('http://localhost:3000/web_api/query', :json_data => data.to_json)
      puts "Response for AUDIOBOOK was: #{response.body}"
  end
  
  task :get_review_stats_for_book => :environment do
    data = {
        'action'  => 'get_review_stats_for_book',
        'book_id' => 30
      }
      
      response = RestClient.post('http://localhost:3000/web_api/query', :json_data => data.to_json)
      puts "Response for BOOK was: #{response.body}"


      data = {
          'action'       => 'get_review_stats_for_book',
          'audiobook_id' => 10
        }

      response = RestClient.post('http://localhost:3000/web_api/query', :json_data => data.to_json)
      puts "Response for AUDIOBOOK was: #{response.body}"
  end
  
  task :get_review_for_book_by_user => :environment do
    data = {
        'action'            => 'get_review_for_book_by_user',
        'book_id'           => 30,
        'user_fbconnect_id' => '1232134'
      }
      
      response = RestClient.post('http://localhost:3000/web_api/query', :json_data => data.to_json)
      puts "Response for BOOK was: #{response.body}"
      
      data = {
          'action'            => 'get_review_for_book_by_user',
          'audiobook_id'      => 10,
          'user_fbconnect_id' => '1232134'
        }

      response = RestClient.post('http://localhost:3000/web_api/query', :json_data => data.to_json)
      puts "Response for AUDIOBOOK was: #{response.body}"      
  end
  
  task :get_user_data => :environment do
    data = {
        'action'  => 'get_user_data',
        'user_fbconnect_id' => '1232134'
      }
      
      response = RestClient.post('http://localhost:3000/web_api/query', :json_data => data.to_json)
      puts "Response was: #{response.body}"
  end
  
  task :update_book_description_from_web_api => :environment do
    data = {
        "book_id"     => 3,
        "action"      => "update_book_description",
        "description" => %q{Upton Sinclair (1878 - 1968) was an American author who wrote over 90 books in several 
genres, 
including the famous novel The Jungle which exposed the horrible conditions of the U.S. meatpacking industry. With the money from this bestseller Sinclair founded a socialist colony in New Jersey, which mysteriously burned to the ground within a year. 

        100%: The Story of a Patriot, is the story is a opportunistic man who gets entangled with a plot to infiltrate and spy on an enclave of Socialists during the Red Scare. The members have been wrongfully connected with a domestic bombing attempt. Sinclair was an political idealist and his Socialist bent is reflected in this book.
        }
      }
    
      response = RestClient.post('http://localhost:3000/web_api', :json_data => data.to_json)
      puts "Response was: #{response.body}"
  end
end