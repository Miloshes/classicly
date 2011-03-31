class ReaderEngineApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  before_filter :get_api_params_and_action

  def create
    if @action != 'process_render_data'
      render :nothing => true
      return
    end
    
    @engine = ReaderEngine.new(:book_id => @api_params['book_id'])
    
    if @engine.handle_incoming_render_data(@api_params)
      render :text => 'SUCCESS' and return
    else
      render :text => 'FAILURE' and return
    end
  end
  
  def query
    @engine = ReaderEngine.new(:book_id => @api_params['book_id'])    
    
    case @action
    when 'get_book_content'
      render :text => @engine.current_book_content
      return
    when 'get_page'
      render :text => @engine.get_page(@api_params['book_id'], @api_params['page_number'])
      return
    end

  end
  
  private
  
  def get_api_params_and_action
    @api_params = ActiveSupport::JSON.decode(params[:json_data]).stringify_keys
    
    # check what to do (and remove it from the parameters)
    @action = @api_params.delete('action')
  end
  
end
