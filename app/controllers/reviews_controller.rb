class ReviewsController < ApplicationController
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
