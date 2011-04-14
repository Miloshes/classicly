class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_return_to
  before_filter :initialize_mixpanel
  before_filter :get_profile_id
  before_filter :set_abingo_identity

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
    Login.where(:fb_connect_id => @profile_id).first
  end

  def user_signed_in?
    @profile_id != nil && Login.exists?(:fb_connect_id => @profile_id)
  end
  
  def admin_user?
    login = current_login
    login.is_admin
  end

  def find_author_collections
    @author_collections = Collection.book_type.by_author
  end

  def find_genre_collections
    @genre_collections = Collection.book_type.by_collection
  end

  def get_profile_id
    @profile_id = Koala::Facebook::OAuth.new(Facebook::APP_ID, Facebook::SECRET).get_user_from_cookies(cookies)
  end
  
  def get_profile_info
    @facebook_cookies = Koala::Facebook::OAuth.new(Facebook::APP_ID, Facebook::SECRET).get_user_info_from_cookies(cookies)
    unless @facebook_cookies.nil?
      graph = Koala::Facebook::GraphAPI.new(@facebook_cookies['access_token'])
      @profile_info =  graph.get_object('me')
    end
  end
  private 

  def set_abingo_identity
    if request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)\b/i
      Abingo.identity = "robot"
    elsif user_signed_in?
      Abingo.identity = @profile_id
    else
      session[:abingo_identity] ||= rand(10 ** 10)
      Abingo.identity = session[:abingo_identity]
    end
  end

end
