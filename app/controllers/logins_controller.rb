class LoginsController < ApplicationController

  def create
    login = Login.register_from_classicly(params, @mixpanel)
    session[:login_id] = login.id
    render :text => ''
  end

  def destroy
    session[:login_id] = nil
    render :text => ''
  end
end
