class Admin::BaseController < ApplicationController
  before_filter :authenticate_user

  def authenticate_user
    unless user_signed_in? && admin_user?
      redirect_to root_url
    end
  end
end
