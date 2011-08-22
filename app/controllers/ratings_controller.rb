class RatingsController < ApplicationController

  def create
    @rateable = find_rateable
    rating = @rateable.ratings.find_or_create_by_fb_connect_id(current_login.fb_connect_id)
    rating.update_attributes!(:score => params[:rating], :rater => current_login)
    render :text => ''
  end

  private

  def find_rateable
    params.each do|name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
  end

end
