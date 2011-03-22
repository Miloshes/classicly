class LoginsController < ApplicationController

  def create
    login = Login.register_from_classicly(params)
    session[:login_id] = login.id
    render :update do |page|
      page << "window.location='%s'" % (session[:return_to] || root_path)
    end
  end

  def destroy
    session[:login_id] = nil
    render :update do |page|
      page << "window.location='%s'" % (session[:return_to] || root_path)
    end
  end
end
