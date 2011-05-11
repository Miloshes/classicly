class PagesController < ApplicationController
  before_filter :find_author_collections
  before_filter :find_genre_collections
  layout "new_design"

  def main
    @featured_book = Book.blessed.random(1).first
    @collection_covers = Collection.where(:name => 'Best Of', :book_type => 'book').first.books.limit(6)
    @books = Book.blessed.random(2)
    @author_collection = Collection.book_type.by_author.first
    # @featured_books = Book.blessed.available.with_description.random(5)
    #     mixpanel_properties = {}
    #     if user_signed_in?
    #       mixpanel_properties.merge({:id => current_login.fb_connect_id})
    #     end
    #     @mixpanel.track_event("Homepage View", mixpanel_properties) if Rails.env.production?
    #     #clear session return_to to avoid redirecting incorrectly
    #     session[:return_to] = nil
  end

  def home_page_author_books_on_json
    #select author collections having 7 or more books to show
    collections = Collection.book_type.select{|collection| collection.books.count >= 7}
    index = rand(collections.count)
    collection = collections[index]
    #send only the ids
    books = Book.joins("INNER JOIN collection_book_assignments ON books.id = collection_book_assignments.book_id WHERE 
      ((collection_book_assignments.collection_id = #{collection.id}))").select('books.id').limit(7)
    render :json => books
  end
  
  def home_page_random_books
    books = Book.blessed.random(12).select('id')
    render :json => books
  end
end
