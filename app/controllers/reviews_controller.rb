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
    review = Review.create_for(current_login, @reviewable, params)
    session[:review] = review  if review.new_record?
    redirect_to author_book_url(@reviewable.author, @reviewable)
  end

  def create_rating
    @reviewable = find_reviewable
    review = @reviewable.reviews.find_or_create_by_fb_connect_id current_login.fb_connect_id
    review.update_attributes! :rating => params[:rating]
  end

  def destroy
    @reviewable = find_reviewable
    review = Review.find(params[:id])
    @reviewable.reviews.delete(review)
    @reviewable.save
    redirect_to author_book_url(@reviewable.author, @reviewable)  
  end

  def show_form
    @book = Book.find(params[:book_id])
    @login = current_login
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
