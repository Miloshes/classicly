class LoginsController < ApplicationController
  before_filter :get_profile_info

  def create
    new_login = Login.register_from_classicly(@profile_info, {:city => params[:city], :country => params[:country]}, @mixpanel)
    render :json =>  {:new_login => new_login}
  end

end
