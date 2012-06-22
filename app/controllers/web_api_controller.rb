require "benchmark"

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

    Rails.logger.info("\n -- response is: #{response.inspect}\n")
    
    render :text => response
  end
  
  # POST review_api/query
  def query
    response = @handler.process_query(params)

    Rails.logger.info("\n -- response is: #{response.inspect}\n")
    
    render :text => response
  end
  
  private
  
  def get_api_handler
    @handler = WebApiHandler.new
  end
  
  def fetch_api_params
    Rails.logger.info("\n -- got params: #{params["json_data"].inspect}\n")

    if params["json_data"].blank?
      @parsed_data = []
    # check if json_data is a Hash without decoding it
    elsif params["json_data"][0] == "{"
      @parsed_data = [ActiveSupport::JSON.decode(params["json_data"]).stringify_keys]
    else
      @parsed_data = ActiveSupport::JSON.decode(params["json_data"]).map(&:stringify_keys)
    end
  end
  
  def authenticate_api_call
    # introducing authentication for API version 1.3 and above
    return true unless call_needs_authentication
    
    correct_signature = Digest::MD5.hexdigest((params["json_data"] || "") + APP_CONFIG["api_secret"])
    
    unless (params["api_key"] == APP_CONFIG["api_key"] && params["api_signature"] == correct_signature)
      Rails.logger.info("\n -- UNAUTHORIZED:\n" +
        "got JSON data: #{params['json_data'].inspect}\n" +
        "expected signature: #{correct_signature}\n" +
        "got signature: #{params['api_signature']}"
      )

      render :nothing => true, :status => :unauthorized
    end
  end
  
  def call_needs_authentication
    # NOTE: API >= 1.3
    @parsed_data.any? do |record|
      if record["structure_version"]
        api_version = Versionomy.parse(record["structure_version"] || "1.0")
        api_version >= "1.3"
      else
        false
      end
    end
  end
  
end
