class FacebookEventsController < ApplicationController
  def like
    response = Net::HTTP.get(URI.parse("http://analytics.performable.com/v1/event?_n=0kM2qj49cTUN&_a=0HuiG9"))
    pp response
    render :text => ''
  end
end
