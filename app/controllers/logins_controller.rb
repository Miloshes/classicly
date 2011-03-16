class LoginsController < ApplicationController

  def create
    #render :text =>  request.env['omniauth.auth'].to_yaml
    omniauth = request.env['omniauth.auth']
    login = Login.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if current_user
      sign_in_and_redirect(:user, current_user)
    elsif login
      sign_in_and_redirect(:user, login.user)
    else
      user = User.new
      user.apply_omniauth(omniauth)
      user.save!
      sign_in_and_redirect(:user, user)
    end
  end

  def index
    @logins = current_user.logins
  end

end
