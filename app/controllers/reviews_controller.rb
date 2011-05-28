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
    review_hash = params[:review].merge!({:reviewer => current_login}) # add reviewer to  attributes
    review = @reviewable.reviews.build(params[:review])
    session[:review] = review  unless review.save
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
