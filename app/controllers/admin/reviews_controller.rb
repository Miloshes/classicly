class Admin::ReviewsController < Admin::BaseController
  layout 'admin'
  before_filter :find_review, except: :index

  def index
    @reviews = Review.includes(:reviewer, :reviewable).page(params[:page]).per(25)
    @reviews = case params[:editors_choice]
      when '1'
        @reviews.where editors_choice: true
      when '0'
        @reviews.where editors_choice: false
      else
        @reviews
    end
  end
  
  def toggle_choice
    @review.toggle :editors_choice
    @review.save
    respond_to do |format|
      format.js { render 'toggle_choice', layout: false }
    end
  end

  def destroy
    @review.delete
    redirect_to admin_reviews_path
  end
  
  private
  def find_review
    @review = Review.find params[:id]
  end
end
