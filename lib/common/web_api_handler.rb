class WebApiHandler
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers  
  
  # creates an IncomingData model object and processes it
  def handle_incoming_data(params)
    incoming_data = IncomingData.create(:json_data => params[:json_data])
    
    if incoming_data
      incoming_data.process!
      return true
    else
      return false
    end
  end
  
  def process_query(params)
    parsed_data = ActiveSupport::JSON.decode(params[:json_data]).stringify_keys

    response = ''

    case parsed_data['action']
    when 'get_reviews_for_book'
      response = get_reviews_for_book(parsed_data)
    when 'get_review_for_book_by_user'
      response = get_review_for_book_by_user(parsed_data)
    when 'get_list_of_books_the_user_wrote_review_for'
      response = get_list_of_books_the_user_wrote_review_for(parsed_data)
    when 'get_book_review_stats'
      response = get_book_review_stats(parsed_data)
    when 'get_classicly_url_for_book'
      response = get_classicly_url_for_book(parsed_data)
    end
    
    return response
  end
  
  def get_reviews_for_book(params)
    book    = Book.find(params['book_id'].to_i)
    reviews = book.reviews.order('created_at DESC').includes('reviewer').page(params['page']).per(params['per_page'] || 25)
    
    result = []
    reviews.each do |review|
      result << {
        :id                  => review.id,
        :title               => review.title,
        :content             => review.content,
        :rating              => review.rating,
        :created_at          => review.created_at,
        :fb_connect_id       => review.reviewer.uid,
        :fb_name             => review.reviewer.first_name + ' ' + review.reviewer.last_name,
        :fb_location_city    => review.reviewer.location_city,
        :fb_location_country => review.reviewer.location_country,
        :fb_location_state   => review.reviewer.location_state
      } 
    end
    
    return result.to_json
  end
  
  def get_review_for_book_by_user(params)
    book = Book.find(params['book_id'])
    user = Login.where(:uid => params['user_fbconnect_id'].to_s, :provider => 'facebook').first()
    
    user.reviews.where(:reviewable => book).first()
  end
  
  def get_list_of_books_the_user_wrote_review_for(params)
    login = Login.where(:uid => params['user_fbconnect_id'].to_s, :provider => 'facebook').first()
    
    books = login.reviews.where(:reviewable_type => 'Book').collect { |review| review.reviewable.id }
    
    return books.to_json
  end
  
  def get_classicly_url_for_book(params)
    default_url_options[:host] = 'www.classicly.com'
    book = Book.find(params[:book_id])
    
    return seo_url(book)
  end
  
end