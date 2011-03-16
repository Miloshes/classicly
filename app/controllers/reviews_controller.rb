class ReviewsController < ApplicationController
  
  # GET /books/:book_id/reviews
  def index
    @reviewable = find_reviewable
    @reviews    = @reviewable.reviews.page(params[:page]).per(params[:per_page] || 25)
    
    respond_to do |format|
      format.html
      format.json { render :json => @reviews.to_json(:except => [:reviewable_id, :reviewable_type]) }
    end
  end
  
  def create
    @reviewable = find_reviewable
    review = @reviewable.reviews.build(params[:review])
    if review.save
      # show something here
    else
      
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
