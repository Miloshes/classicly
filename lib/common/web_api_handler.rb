require "benchmark"

class WebApiHandler
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers  
  
  # creates an IncomingData model object and processes it
  def handle_incoming_data(params)
    # TODO: 
    # The problem is that the API structure version is inside the json_data, so we can't check against it.
    # Originally we're returning "FAILURE", but for API v >= 1.3 the response should be json
    return "FAILURE" if params[:json_data].blank?
    
    incoming_data = IncomingData.create(:json_data => params[:json_data])
    response      = incoming_data.process!

    return response
  end
  
  def process_query(params)

    response = ""

    benchmark_result = Benchmar.measure {
      parsed_data = ActiveSupport::JSON.decode(params[:json_data]).stringify_keys

      case parsed_data["action"]
      when "get_reviews_for_book"
        response = get_reviews_for_book(parsed_data)
      when "get_ratings_for_all_books"
        response = get_ratings_for_all_books(parsed_data)
      when "get_review_for_book_by_user"
        response = get_review_for_book_by_user(parsed_data)
      when "get_list_of_books_the_user_wrote_review_for"
        response = get_list_of_books_the_user_wrote_review_for(parsed_data)
      when "get_review_stats_for_book"
        response = get_review_stats_for_book(parsed_data)
      when "get_classicly_url_for_book"
        response = get_classicly_url_for_book(parsed_data)
      when "get_user_data"
        response = get_user_data(parsed_data)
      when "get_book_highlights_for_user_for_book"
        response = get_book_highlights_for_user_for_book(parsed_data)
      when "get_tweet_and_facebook_share_texts"
        response = get_tweet_and_facebook_share_texts(parsed_data)
      end
    }

    Rails.logger.info("\n - benchmark [process_query]: #{benchmark_result}\n")
    
    return response
  end
  
  def get_reviews_for_book(params)
    page     = params['page']
    per_page = params['per_page'] || 25
    
    if params['book_id']
      book = Book.find(params['book_id'].to_i)
    else
      book = Audiobook.find(params['audiobook_id'].to_i)
    end
    
    reviews = book.reviews.order('created_at DESC, id DESC').includes('reviewer').page(page).per(per_page)
    
    result = []
    reviews.each do |review|
      # should never happen, but need a fallback for test cases
      next if review.reviewer.blank?
      
      result << {
        :content             => review.content || "",
        :rating              => review.rating,
        :created_at          => review.created_at,
        :email               => review.reviewer.email || "",
        :fb_connect_id       => review.reviewer.fb_connect_id || "",
        :fb_name             => (review.reviewer.first_name || "") + " " + (review.reviewer.last_name || ""),
        :fb_location_city    => review.reviewer.location_city || "",
        :fb_location_country => review.reviewer.location_country || "",
      } 
    end
    
    return result.to_json
  end
  
  def get_ratings_for_all_books(params)
    if params['book_type'] == 'book'
      books = Book.where(:avg_rating.gt => 0).all()
    else
      books = Audiobook.where(:avg_rating.gt => 0).all()
    end
    
    result = {}
    
    books.each do |book|
      result[book.id] = book.avg_rating.to_s
    end
    
    return result.to_json
  end
  
  def get_list_of_books_the_user_wrote_review_for(params)
    login = Login.find_user(params["user_email"], params["user_fbconnect_id"], params["device_ss_id"])
    
    return [].to_json if login.blank?
    
    result = []
    
    case params['structure_version']
    # TODO: API version fix (this should be nicer)
    when '1.2', '1.3', '1.4'
      result = {
        :books => login.reviews.where(:reviewable_type => 'Book').collect { |review|
          {:id => review.reviewable_id, :rating => review.rating}
        },
        :audiobooks => login.reviews.where(:reviewable_type => 'Audiobook').collect { |review|
          {:id => review.reviewable_id, :rating => review.rating}
        }
      }
    when '1.1'
      book_ids = login.reviews.where(:reviewable_type => 'Book').collect { |review| review.reviewable_id }
      audiobook_ids = login.reviews.where(:reviewable_type => 'Audiobook').collect { |review| review.reviewable_id }
      
      result = {
        :book_ids => book_ids,
        :audiobook_ids => audiobook_ids
      }
    else
      result = login.reviews.where(:reviewable_type => 'Book').collect { |review| review.reviewable.id }
    end
    
    return result.to_json
  end
  
  def get_classicly_url_for_book(params)
    default_url_options[:host] = 'www.classicly.com'
    
    if params['book_id']
      book = Book.find(params['book_id'].to_i)
    else
      book = Audiobook.find(params['audiobook_id'].to_i)
    end
    
    return author_book_url(book.author, book).to_json
  end
  
  def get_review_stats_for_book(params)
    default_url_options[:host] = 'www.classicly.com'

    if params['book_id']
      book = Book.find(params['book_id'].to_i)
    else
      book = Audiobook.find(params['audiobook_id'].to_i)
    end

    # NOTE:
    # book_review_count = count(reviews by users with a classicly account) - can be a written review or just a rating
    # book_written_review_count = count(reviews that has content by users with a classicly account)
    # comment: we're not adding anonymous_reviews to the written review counts, as by current definition anony reviews
    # can't have content even if the model supports it
    return {
      :book_rating_average       => book.avg_rating,
      :book_review_count         => book.reviews.count,
      :book_written_review_count => book.reviews.where(:content.not_eq => nil).count,
      :classicly_url             => author_book_url(book.author, book)
    }.to_json
  end
  
  def get_review_for_book_by_user(params)
    if params["book_id"]
      book = Book.find(params["book_id"].to_i)
    else
      book = Audiobook.find(params["audiobook_id"].to_i)
    end
    
    return nil.to_json if book.blank?
    
    if params["user_fbconnect_id"] || params["user_email"]
      
      login = Login.find_user(params["user_email"], params["user_fbconnect_id"])
      
      return nil.to_json if login.blank?
      
      review = Review.where(:reviewable => book, :reviewer => login).first()
      
      return nil.to_json if review.blank?
      
      return {
          :content    => review.content || "",
          :rating     => review.rating,
          :created_at => review.created_at
        }.to_json
    else
      review = AnonymousReview.where(:reviewable => book, :ios_device_id => params["device_id"].to_s).first()
      
      # for device_id only reviews, they don't have content so we're not sending it back
      return {:rating => review.rating, :created_at => review.created_at}.to_json
    end
  end
  
  def get_user_data(params)
    login = Login.where(:fb_connect_id => params['user_fbconnect_id'].to_s).first()
    
    return login.to_json(:only => [:first_name, :last_name, :location_city, :location_country, :email, :fb_connect_id, :twitter_name])
  end
  
  def get_book_highlights_for_user_for_book(params)
    book  = Book.find(params["book_id"].to_i)

    # Look up user based on his Classicly accounts email address, fall back to Facebook ID, then fall back to device ID
    # which would yield the same user nevertheless - this is for safety measures
    login = Login.find_user(params["user_email"], params["user_fbconnect_id"], params["device_ss_id"])
        
    return nil.to_json if book.blank?
    
    anonymous_highlights = AnonymousBookHighlight.where(
        "book_id = ? AND ios_device_ss_id IN (?)", book.id, login.ios_devices.collect(&:ss_udid)
      ).all()
    
    highlights = []
    if !login.blank?
      highlights = BookHighlight.where(:book => book, :user => login).all()
    end
    
    # NOTE: thing is, one user should have either normal highlights or anonymous ones - this is for safety measures
    all_highlights = anonymous_highlights + highlights
    
    result = all_highlights.collect { |highlight|
        {
          :first_character => highlight.first_character,
          :last_character  => highlight.last_character,
          :content         => highlight.content,
          :created_at      => highlight.created_at,
          :origin_comment  => highlight.origin_comment
        }
      }
    
    return result.to_json
  end
  
  def get_tweet_and_facebook_share_texts(call_params)
    share_message_handler = ShareMessageHandler.new

    params = {}

    params[:target_platform] = call_params["platform"]
    params[:message_type]    = call_params["message_type"]

    if call_params["book_id"]
      params[:book] = Book.find(call_params["book_id"].to_i)
    else
      params[:book] = Audiobook.find(call_params["audiobook_id"].to_i)
    end
    
    params[:apple_id] = call_params["apple_id"]
    params[:selected_text] = call_params["selected_text"]
    
    response = share_message_handler.get_message_for(params)
    
    # we're putting the twitter message into it's own Hash, so it's easier to parse on the client side
    if params[:target_platform] == "twitter"
      response = {:twitter_message => response}
    end
    
    return response.to_json
  end
  
end