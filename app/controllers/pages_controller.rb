class PagesController < ApplicationController
  before_filter :find_author_collections
  before_filter :find_genre_collections
  layout "new_design"

  def main
    @featured_book = Book.blessed.random(1).first
    @random_book = Book.random(1).select('id').first
    @collection_covers = Collection.where(:name => 'Best Of', :book_type => 'book').first.books.limit(6)
    # @featured_books = Book.blessed.available.with_description.random(5)
    #     mixpanel_properties = {}
    #     if user_signed_in?
    #       mixpanel_properties.merge({:id => current_login.fb_connect_id})
    #     end
    #     @mixpanel.track_event("Homepage View", mixpanel_properties) if Rails.env.production?
    #     #clear session return_to to avoid redirecting incorrectly
    #     session[:return_to] = nil
  end

end
