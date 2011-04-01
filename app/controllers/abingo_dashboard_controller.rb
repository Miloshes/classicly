class AbingoDashboardController < ApplicationController
  #TODO add some authorization
  layout 'abingo'
  include Abingo::Controller::Dashboard
  before_filter :authenticate_user

  private
  def authenticate_user
    unless user_signed_in? && admin_user?
      redirect_to root_url
    end
  end
end
