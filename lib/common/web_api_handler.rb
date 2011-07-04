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
    when 'get_ratings_for_all_books'
      response = get_ratings_for_all_books(parsed_data)
    when 'get_review_for_book_by_user'
      response = get_review_for_book_by_user(parsed_data)
    when 'get_list_of_books_the_user_wrote_review_for'
      response = get_list_of_books_the_user_wrote_review_for(parsed_data)
    when 'get_review_stats_for_book'
      response = get_review_stats_for_book(parsed_data)
    when 'get_classicly_url_for_book'
      response = get_classicly_url_for_book(parsed_data)
    when 'get_user_data'
      response = get_user_data(parsed_data)
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
      result[book.id] = book.avg_rating
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
  
end