class LoginsController < ApplicationController
  before_filter :get_profile_info

  def create
    new_login = Login.register_from_classicly(@profile_info, {:city => params[:city], :country => params[:country]}, @mixpanel)
    
    # if it was a new login, save the user's library which is a session-only library right now
    if new_login
      current_library.save
    end
    
    render :json =>  {:new_login => new_login}
  end

end
