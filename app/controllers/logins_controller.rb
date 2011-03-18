class LoginsController < ApplicationController

  def create
    omniauth = request.env['omniauth.auth']
    login = Login.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if current_user
      sign_in_and_redirect(:user, current_user)
    elsif login
      sign_in(:user, login.user)
      redirect_back_or_default
    else
      user = User.new
      user.apply_omniauth(omniauth)
      user.save!
      sign_in(:user, user)
      redirect_back_or_default
    end
  end

  def index
    @logins = current_user.logins
  end

end
