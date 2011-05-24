class PagesController < ApplicationController
  layout "new_design"

  def audiobook_authors
    @collections = Collection.of_type('audiobook').collection_type('author').random(10)
    @featured = @collections[rand(@collections.size)]
    @viewing_audibly = true
    render 'authors', :layout => 'audibly'
  end
  
  def audio_collections
    @collections = Collection.of_type('audiobook').collection_type('collection').random(10)
    @featured = @collections[rand(@collections.size)]
    @viewing_audibly = true
    render 'collections', :layout => 'audibly'
  end
    
  def authors
    @collections = Collection.book_type.by_author.random(10)
    @featured = @collections[rand(@collections.size)]
  end

  def collections
    @collections = Collection.book_type.by_collection.random(10)
    @featured = @collections.first
  end
  

  def main
    @featured_book = Book.select([:id, :pretty_title, :author_id, :cached_slug]).blessed.first
    @collection_covers = Collection.where(:name => 'Best Of', :book_type => 'book').first.books.limit(6)
    @books = Book.blessed.select([:id, :pretty_title, :author_id, :cached_slug])
    @author_collection, @author_collection_books = Book.books_from_random_collection('author', 1, ['books.id', 'author_id', 'cached_slug', 'pretty_title']) 
    # @featured_books = Book.blessed.available.with_description.random(5)
    #     mixpanel_properties = {}
    #     if user_signed_in?
    #       mixpanel_properties.merge({:id => current_login.fb_connect_id})
    #     end
    #     @mixpanel.track_event("Homepage View", mixpanel_properties) if Rails.env.production?
    #     #clear session return_to to avoid redirecting incorrectly
    #     session[:return_to] = nil
  end

  def random_json_books
    books = Book.blessed.no_squat_image.select('books.id, author_id, cached_slug, pretty_title').random(params[:total_books].to_i)
    render :json => Book.hashes_for_JSON(books)
  end
end
