class ReviewApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  before_filter :get_api_handler
  
  def create
    if @handler.handle_incoming_data(params)
      render :text => 'SUCCESS' and return
    else
      render :text => 'FAILURE' and return
    end
  end
  
  # POST review_api/query
  def query
    response = @handler.process_query(params[:json_data])
    
    render :text => response
  end
  
  private
  
  def get_api_handler
    @handler = ReviewApiHandler.new
  end
  
end
