class WebApiController < ApplicationController
  
  skip_before_filter :verify_authenticity_token

  skip_before_filter :collections_for_footer
  skip_before_filter :set_abingo_identity
  skip_before_filter :popular_collections
  
  before_filter :get_api_handler
  before_filter :fetch_api_params
  before_filter :authenticate_api_call
  
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
  
  def fetch_api_params

    if params["json_data"].blank?
      @parsed_data = []
    # check if json_data is a Hash without decoding it
    elsif params["json_data"][0] == "{"
      @parsed_data = [ActiveSupport::JSON.decode(params["json_data"]).stringify_keys]
      Rails.logger.info("\n - ARRAY: #{@parsed_data.inspect}\n")
    else
      @parsed_data = ActiveSupport::JSON.decode(params["json_data"]).map(&:stringify_keys)
      Rails.logger.info("\n - HASH: #{@parsed_data.inspect}\n")
    end
  end
  
  def authenticate_api_call
    # introducing authentication for API version 1.3 and above
    return true unless call_needs_authentication
    
    Rails.logger.info("\n - Has to authenticate!\n")

    correct_signature = Digest::MD5.hexdigest((params["json_data"] || "") + APP_CONFIG["api_secret"])
    
    unless (params["api_key"] == APP_CONFIG["api_key"] && params["api_signature"] == correct_signature)
      render :nothing => true, :status => :unauthorized
    end
  end
  
  def call_needs_authentication
    # TODO: API >= 1.3
    @parsed_data.any? do |record|
      record["structure_version"] == "1.3"
    end
  end
  
end
