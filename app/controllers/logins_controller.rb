class LoginsController < ApplicationController

  def create
    @current_login, is_new_login = Login.register_from_classicly(fetch_user_profile_from_fb)
    render :json => { :is_new_login => is_new_login }
  end

  def unsubscribe
    @login = Login.find_by_email params[:address]

    # return if the user has already taken himself out of the mailing or if the token is not valid
    if @login.mailing_enabled == false || params[:address].nil? || params[:token].nil? || @login.access_token != params[:token]
      redirect_to root_path
    end

    if params[:confirm] && params[:confirm] == "yes"
      @login.update_attributes(:mailing_enabled => false, :access_token => nil)
      @added_to_blacklist = true
    end

  end

  private

  def fetch_user_profile_from_fb
    graph_api    = Koala::Facebook::GraphAPI.new(facebook_cookies["access_token"])
    profile_info = graph_api.get_object("me")
  end

end
