class LoginsController < ApplicationController

  def create
    @current_login, is_new_login = Login.register_from_classicly(fetch_user_profile_from_fb)
    render :json => { :is_new_login => is_new_login }
  end
  
  def unsubscribe
    @login = Login.find_by_fb_connect_id params[:id]
    redirect_to root_path if @login.mailing_enabled == false
    
    if params[:confirm] && params[:confirm] == 'yes'
      @login.update_attribute :mailing_enabled, false
      @added_to_blacklist = true
    end
  end

  private

  def fetch_user_profile_from_fb
    graph_api    = Koala::Facebook::GraphAPI.new(facebook_cookies['access_token'])
    profile_info = graph_api.get_object('me')
  end

end
