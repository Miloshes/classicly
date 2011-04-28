class PagesController < ApplicationController
  before_filter :find_author_collections
  before_filter :find_genre_collections

  def main
    response.headers['Cache-Control'] = 'public, max-age=60'
    @related_books = Book.blessed.random(8)
    @featured_books = Book.blessed.available.with_description.random(5)
    mixpanel_properties = {}
    if user_signed_in?
      mixpanel_properties.merge({:id => current_login.fb_connect_id})
    end
    @mixpanel.track_event("Homepage View", mixpanel_properties) if Rails.env.production?
    #clear session return_to to avoid redirecting incorrectly
    session[:return_to] = nil
  end

end
