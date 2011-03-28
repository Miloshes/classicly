class ReviewsController < ApplicationController
  
  # GET /books/:book_id/reviews
  def index
    @reviewable = find_reviewable
    @reviews    = @reviewable.reviews.order('id DESC').page(params[:page]).per(params[:per_page] || 25)
    
    respond_to do |format|
      format.html
      format.json { render :json => @reviews.to_json(:except => [:reviewable_id, :reviewable_type]) }
    end
  end
  
  def create
    @reviewable = find_reviewable
    #the following until the UI for rating and title is completed
    params[:review][:rating] ||= 5
    review_hash = params[:review].merge!({:reviewer => current_login}) # add reviewer to  attributes
    review = @reviewable.reviews.build(params[:review])
    if review.save
      @mixpanel.track_event("Review Left", {:id => current_login.fb_connect_id})
    else
      session[:review] = review # save review to show errors
    end
    redirect_to author_book_url(@reviewable.author, @reviewable)  
  end
  
  def destroy
    @reviewable = find_reviewable
    review = Review.find(params[:id])
    @reviewable.reviews.delete(review)
    @reviewable.save
    redirect_to author_book_url(@reviewable.author, @reviewable)  
  end

  private
  def find_reviewable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end

end
