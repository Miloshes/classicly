class LoginsController < ApplicationController
  before_filter :get_profile_info

  def create
    login = Login.register_from_classicly(@profile_info, {:city => params[:city], :country => params[:country]}, @mixpanel)
    render :text => ''
  end
end
