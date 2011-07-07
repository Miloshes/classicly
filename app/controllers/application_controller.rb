class ApplicationController < ActionController::Base
  include LibrarySessionHandler
  
  layout 'new_design'
  protect_from_forgery
  helper_method :current_admin_user_session, :current_admin_user, :current_login
  
  
  # IMPORTANT NOTE: we have an iOS API, so web related before filters should be skipped in web_api_controller.
  # Update it's skip_before_filter list when adding stuff here.
  before_filter :collections_for_footer
  before_filter :set_abingo_identity
  before_filter :popular_collections
  caches_action :collections_for_footer
  
  def current_login
    @current_login ||= Login.where(:fb_connect_id => @profile_id).first
  end

  def collections_for_footer
    @collections_for_footer = Collection.of_type('book').collection_type('collection').limit(14).order('name asc')
    @author_collections_for_footer = Collection.of_type('book').collection_type('author').limit(14).order('name asc')
 end
  
  def current_admin_user_session
    return @current_admin_user_session if defined?(@current_admin_user_session)
    @current_admin_user_session = AdminUserSession.find
  end

  def current_admin_user
    return @current_admin_user if defined?(@current_admin_user)
    @current_admin_user = current_admin_user_session && current_admin_user_session.admin_user
  end

  def popular_collections
    @popular_collections = Collection.of_type('book').random(1).select('id')
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
 
  def set_abingo_identity
    if request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)\b/i
      Abingo.identity = "robot"
    elsif current_admin_user
      Abingo.identity = @profile_id
    else
      session[:abingo_identity] ||= rand(10 ** 10)
      Abingo.identity = session[:abingo_identity]
    end
  end
end
