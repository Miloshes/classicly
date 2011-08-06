class LoginsController < ApplicationController

  def create
    @current_login, is_new_login = Login.register_from_classicly(fetch_user_profile_from_fb)
    render :json => { :is_new_login => is_new_login }
  end

  private

  def fetch_user_profile_from_fb
    graph_api    = Koala::Facebook::GraphAPI.new(facebook_cookies['access_token'], :ca_path => '/usr/lib/ssl/certs/ca-certificates.crt')
    profile_info = graph_api.get_object('me')

    return profile_info
  end

end
