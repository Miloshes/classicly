class Admin::ReviewsController < Admin::BaseController
  layout 'admin'
  before_filter :find_review, except: :index

  def index
    @reviews = Review.includes(:reviewer, :reviewable).page(params[:page]).per(25)
    @reviews = case params[:featured]
      when '1'
        @reviews.featured
      when '0'
        @reviews.where featured: false
      else
        @reviews
    end
  end
  
  def toggle_featured
    @review.toggle :featured
    @review.save
    respond_to do |format|
      format.js { render 'toggle_featured', layout: false }
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
