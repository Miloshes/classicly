class LoginsController < ApplicationController

  def create
    @current_login, is_new_login = Login.register_from_classicly(fetch_user_profile_from_fb)
    render :json => { :is_new_login => is_new_login }
  end

  def unsubscribe
    # fallback - missing required parameters
    if params[:address].blank? || params[:token].blank?
      redirect_to root_path
      return
    end

    @login = Login.where(:email => params[:address], :access_token => params[:token]).first()

    # fallback - haven't found the user or the token wasn't right
    if @login.blank?
      redirect_to root_path
      return
    end

    if params[:confirm] && params[:confirm] == "yes"
      @login.update_attributes(:mailing_enabled => false, :access_token => nil)
      render :action => "confirmed_unsubscription"
    else
      render :action => "unsubscribe_warning"
    end
  end

  private

  def fetch_user_profile_from_fb
    graph_api    = Koala::Facebook::GraphAPI.new(facebook_cookies["access_token"])
    profile_info = graph_api.get_object("me")
  end

end
