class WebApiController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  skip_before_filter :collections_for_footer
  skip_before_filter :set_abingo_identity
  
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
    response = @handler.process_query(params)
    
    render :text => response
  end
  
  private
  
  def get_api_handler
    @handler = WebApiHandler.new
  end
  
end
