class ReviewApiHandler
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
    parsed_data = ActiveSupport::JSON.decode(self.json_data).stringify_keys

    case record['action']
    when 'get_reviews_for_book'
      get_reviews_for_book(parsed_data)
    when 'get_review_for_book_by_user'
      get_review_for_book_by_user(parsed_data)
    when 'get_list_of_books_the_user_wrote_review_for'
      get_list_of_books_the_user_wrote_review_for(parsed_data)
    when 'get_book_review_stats'
      get_book_review_stats(parsed_data)
    when 'get_classicly_url_for_book'
      get_classicly_url_for_book(parsed_data)
    end
  end
  
  def get_reviews_for_book(params)
    book    = Book.find(params['book_id'])
    reviews = book.reviews.order('id DESC').page(params['page']).per(params['per_page'] || 25)
    
    return reviews.to_json(:except => [:reviewable_id, :reviewable_type])
  end
  
  def get_review_for_book_by_user(params)
    book = Book.find(params['book_id'])
    user = Login.where(:uid => data['user_fbconnect_id'], :provider => 'facebook').first().user
    
    user.reviews.where(:reviewable => book).first()
  end
  
  def get_list_of_books_the_user_wrote_review_for(params)
    book = Book.find(params['book_id'])
    user = Login.where(:uid => data['user_fbconnect_id'], :provider => 'facebook').first().user
    
    books = user.reviews.where(:reviewable_type => 'Book').collect { |review| review.reviewable }
    
    return books
  end
  
  def get_classicly_url_for_book(params)
    default_url_options[:host] = 'www.classicly.com'
    book = Book.find(params[:book_id])
    
    return seo_url(book)
  end
  
end