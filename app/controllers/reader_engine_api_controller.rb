class ReaderEngineApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  before_filter :get_engine
  
  def create
    if @engine.handle_incoming_render_data(params)
      render :text => 'SUCCESS' and return
    else
      render :text => 'FAILURE' and return
    end
  end
  
  private
  
  def get_engine
    @engine = ReaderEngine.new
  end
  
end
