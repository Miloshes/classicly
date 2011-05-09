class Admin::ReviewsController < Admin::BaseController
  layout 'admin'

  def index
    @reviews = Review.page(params[:page]).per(25)
  end

  def destroy
    review = Review.find params[:id]
    review.delete
    redirect_to admin_reviews_path
  end
end
