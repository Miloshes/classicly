class WebApiHandler
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers  
  
  # creates an IncomingData model object and processes it
  def handle_incoming_data(params)
    return "FAILURE" if params[:json_data].blank?
    
    incoming_data = IncomingData.create(:json_data => params[:json_data])
    response      = incoming_data.process!

    return response
  end
  
  def process_query(params)
    parsed_data = ActiveSupport::JSON.decode(params[:json_data]).stringify_keys

    response = ""

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
        :content             => review.content || '',
        :rating              => review.rating,
        :created_at          => review.created_at,
        :fb_connect_id       => review.reviewer.fb_connect_id,
        :fb_name             => review.reviewer.first_name + ' ' + review.reviewer.last_name,
        :fb_location_city    => review.reviewer.location_city,
        :fb_location_country => review.reviewer.location_country,
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
  
  # TODO: check what's this for. Do we have to include anonymous reviews?
  def get_list_of_books_the_user_wrote_review_for(params)
    if params['user_fbconnect_id']
      login = Login.where(:fb_connect_id => params['user_fbconnect_id'].to_s).first()
    else
      login = Login.where(:ios_device_id => params['device_id'].to_s).first()
    end
    
    return [].to_json if login.blank?
    
    result = []
    
    case params['structure_version']
    when '1.2'
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
    
    return {
        :book_rating_average => book.avg_rating,
        :book_review_count   => book.reviews.where('fb_connect_id IS NOT NULL').count,
        :classicly_url       => author_book_url(book.author, book)
      }.to_json
  end
  
  def get_review_for_book_by_user(params)
    if params['book_id']
      book = Book.find(params['book_id'].to_i)
    else
      book = Audiobook.find(params['audiobook_id'].to_i)
    end
    
    return nil.to_json if book.blank?
    
    if params['user_fbconnect_id']
      login  = Login.where(:fb_connect_id => params['user_fbconnect_id'].to_s).first()
      review = Review.where(:reviewable => book, :reviewer => login).first()
      
      return nil.to_json if login.blank? || review.blank?
      
      return {
          :content    => review.content || '',
          :rating     => review.rating,
          :created_at => review.created_at
        }.to_json
    else
      review = AnonymousReview.where(:reviewable => book, :ios_device_id => params['device_id'].to_s).first()
      
      # for device_id only reviews, they don't have content so we're not sending it back
      return {:rating => review.rating, :created_at => review.created_at}.to_json
    end
  end
  
  def get_user_data(params)
    login = Login.where(:fb_connect_id => params['user_fbconnect_id'].to_s).first()
    
    return login.to_json(:except => [:id, :user_id])
  end
  
  def get_book_highlights_for_user_for_book(params)
    book  = Book.find(params["book_id"].to_i)

    # We should get the same user nevertheless - this is for safety measures
    if params["user_fbconnect_id"]
      login = Login.where(:fb_connect_id => params["user_fbconnect_id"].to_s).first()
    else
      login = IosDevice.find_by_ss_udid(params["device_ss_id"].to_s).user
    end
    
    return nil.to_json if book.blank? || login.blank?
    
    anonymous_highlights = AnonymousBookHighlight.where(
        "book_id = ? AND ios_device_ss_id IN (?)", book.id, login.ios_devices.collect(&:ss_udid)
      ).all()
      
    highlights = BookHighlight.where(:book => book, :user => login).all()
    
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