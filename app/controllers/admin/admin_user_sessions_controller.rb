class Admin::AdminUserSessionsController < Admin::BaseController
  before_filter :require_no_admin_user, :only => [:new, :create]
  before_filter :require_admin_user, :only => :destroy
 
  def new
    @admin_user_session = AdminUserSession.new
  end
 
  def create
    @admin_user_session = AdminUserSession.new(params[:admin_user_session])
    if @admin_user_session.save
      flash[:notice] = "Login successful!"
      redirect_to admin_root_path
    else
      render :action => :new
    end
  end
 
  def destroy
    current_admin_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_to root_url
  end
end