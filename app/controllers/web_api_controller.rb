class WebApiController < ApplicationController
  
  skip_before_filter :verify_authenticity_token

  skip_before_filter :collections_for_footer
  skip_before_filter :set_abingo_identity
  skip_before_filter :popular_collections
  
  before_filter :get_api_handler
  
  def create
    response = @handler.handle_incoming_data(params)
    
    render :text => response
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
