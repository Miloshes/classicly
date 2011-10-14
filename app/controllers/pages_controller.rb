class PagesController < ApplicationController
  before_filter :km_init

  def about
  end

  def apps
    
  end
  
  def audiobook_authors
    @featured     = Collection.find_audiobook_author_collections.with_description.random(1).first if params[:page].nil?
    @collections  = Collection.find_audiobook_author_collections.order('name asc').page(params[:page]).per(12)
    @collections  = @collections.where(:id.not_eq => @featured.id) if @featured
    render 'authors', :layout => 'audibly'
  end

  def audio_collections
    @featured     = Collection.find_audiobook_collections_and_genres.with_description.random(1).first if params[:page].nil?
    @collections  = Collection.find_audiobook_collections_and_genres.order('name asc').page(params[:page]).per(12)
    @collections  = @collections.where(:id.not_eq => @featured.id) if @featured
    render 'collections', :layout => 'audibly'
  end

  def authors
    @featured     = Collection.find_book_author_collections.with_description.random(1).first if params[:page].nil?
    @collections  = Collection.find_book_author_collections.order('name asc').page(params[:page]).per(12)
    @collections  = @collections.where(:id.not_eq => @featured.id) if @featured
  end

  def collections
    @featured     = Collection.find_book_collections_and_genres.with_description.random(1).select('id, name, parsed_description, cached_slug, book_type').first if params[:page].nil?
    @collections  = Collection.find_book_collections_and_genres.order('name asc').page(params[:page]).per(12)
    @collections  = @collections.where(:id.not_eq => @featured_collection.id) if @featured_collection
  end
  
  def dmca
    
  end
  
  def ipad
    KM.record("Redirected iPad request")
    redirect_to 'http://itunes.apple.com/us/app/free-books-23-469-classics/id364612911?mt=8'
  end
  
  def iphone
    KM.record("Redirected iPhone request")
    redirect_to 'http://itunes.apple.com/us/app/free-books-23-469-classics/id317776727?mt=8'
  end
  
  def main
    @featured_book  = Book.blessed.select("books.id, author_id, cached_slug, pretty_title").random(1).first
    @column_books   = Book.blessed.select("books.id, author_id, cached_slug, pretty_title").random(9)
  end

  def privacy
  end
  
  def terms_of_service
    
  end
  
  protected
  
  def km_init
    KM.init('95fd99a5f08a7e3b66a3ec13482c021a3fe30872', 
            :log_dir => File.join(Rails.root.to_s, 'log', 'km'),
            :env => Rails.env)

    unless identity = cookies[:km_identity]
      identity = generate_identifier
      cookies[:km_identity] = { :value => identity, :expires => 5.years.from_now}
    end

    if current_login
      
      unless cookies[:km_aliased]
        KM.alias(identity, current_login.email)
        cookies[:km_aliased] = {:value => true, :expires => 5.years.from_now }
      end
      
      identity = current_login.email
    end
    
    KM.identify(identity)
  end
  
  def generate_identifier
    now = Time.now.to_i  
    Digest::MD5.hexdigest( (request.referrer || '') + rand(now).to_s + now.to_s + (request.user_agent || ''))
  end

end
