class ApplicationController < ActionController::Base
  layout 'new_design'

  protect_from_forgery
  helper_method :current_admin_user_session, :current_admin_user
  before_filter :collections_for_footer
  before_filter :initialize_indextank
  before_filter :set_abingo_identity

  def initialize_indextank
    @indextank ||= IndexTankInitializer::IndexTankService.get_index('classicly_staging')
  end


  def collections_for_footer
    @collections_for_footer = Collection.by_author.limit(14)
    @collections_for_footer += Collection.by_collection.limit(14)
  end
  
  def current_admin_user_session
    return @current_admin_user_session if defined?(@current_admin_user_session)
    @current_admin_user_session = AdminUserSession.find
  end

  def current_admin_user
    return @current_admin_user if defined?(@current_admin_user)
    @current_admin_user = current_admin_user_session && current_admin_user_session.admin_user
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
