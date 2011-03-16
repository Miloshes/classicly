class IncomingDatasController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def create
    response = ""
    
    incoming_data = IncomingData.create(:json_data => params[:json_data])
    
    if incoming_data
      response = "SUCCESS"
    else
      response = "FAILURE"
    end
    
    incoming_data.process!
    
    render :text => response
  end
  
end
