class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :find_author_collections
  before_filter :find_genre_collections
  before_filter :set_return_to
  before_filter :initialize_mixpanel

  def initialize_mixpanel
    @mixpanel = Mixpanel.new("b6f94d510743ff0037009f3a1be605c2", request.env, true)
  end

  def redirect_back_or_default
    redirect_to session[:return_to] || root_path
  end

  def set_return_to
    session['return_to'] = (request.fullpath =~ /\/\w+/) && !(request.fullpath =~ /\/auth\/facebook/ || request.fullpath =~ /\/logins/)? request.fullpath : session['return_to']
  end

  protected

  def current_login
    Login.find(session[:login_id])
  end

  def user_signed_in?
    session[:login_id] && Login.exists?(session[:login_id])
  end

  def find_author_collections
    @author_collections = Collection.book_type.by_author
  end

  def find_genre_collections
    @genre_collections = Collection.book_type.by_collection
  end
end
