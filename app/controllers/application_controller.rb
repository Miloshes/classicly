class ApplicationController < ActionController::Base
  include LibrarySessionHandler
  include LoggerHelper

  layout 'new_design'

  protect_from_forgery
  helper_method :current_admin_user_session, :current_admin_user, :current_login

  # IMPORTANT NOTE: we have an iOS API, so web related before filters should be skipped in web_api_controller.
  # Update it's skip_before_filter list when adding stuff here.
  before_filter :popular_books
  before_filter :popular_collections
  
  before_filter do
    @show_right_nav = true
  end

  def current_login
    return nil if facebook_cookies.blank?

    @current_login ||= Login.where(:fb_connect_id => facebook_cookies["user_id"]).first
  end

  def current_admin_user_session
    return @current_admin_user_session if defined?(@current_admin_user_session)
    @current_admin_user_session = AdminUserSession.find
  end

  def current_admin_user
    return @current_admin_user if defined?(@current_admin_user)
    @current_admin_user = current_admin_user_session && current_admin_user_session.admin_user
  end
  
  def popular_audiobooks
    @popular_audiobooks = Audiobook.blessed.select("id, author_id, cached_slug, pretty_title").random(3)
  end

  def popular_books
    @popular_books = Book.blessed.select("books.id AS id, author_id, cached_slug, pretty_title").random(3)
  end

  def popular_collections
    @popular_collections = Collection.of_type('book').random(1).select('id, cached_slug, name')
  end

  def require_admin_user
    unless current_admin_user
      flash[:notice] = "You must be logged in to access this page"
      redirect_to admin_sign_in_path
      return false
    end
    true
  end

  def require_no_admin_user
    if current_admin_user
      flash[:notice] = "You must be logged out to access this page"
      redirect_to root_path
      return false
    end
  end

  def facebook_cookies
    if session[:facebook_cookies].blank?
      begin
        session[:facebook_cookies] = Koala::Facebook::OAuth.new(Facebook::APP_ID, Facebook::SECRET).get_user_info_from_cookies(cookies)
      rescue Exception
      end
    end

    return session[:facebook_cookies]
  end

end
