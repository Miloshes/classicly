class LoginsController < ApplicationController

  def create
    login = Login.find_or_new_login_api(params[:uid], params[:first_name], params[:last_name], params[:email], params[:city], params[:state], params[:country])
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
