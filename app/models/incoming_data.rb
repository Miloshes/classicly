# Model to temporary hold and then process incoming data that's coming from our iOS client apps
class IncomingData < ActiveRecord::Base
  validates :json_data, :presence => true

  # Note:
  # Incoming data should have an action field to describe what to do with the data (easily extensible)
  def process!
    return true if self.processed
    
    parsed_data = ActiveSupport::JSON.decode(self.json_data)

    # if we're dealing with 1 data record and not an array, convert to array
    if parsed_data.is_a? Hash
      parsed_data = [parsed_data]
    end
    
    # the sub-tasks can override it
    response = "SUCCESS"

    parsed_data.each do |record|
      case record["action"]
      # stands for creating and updating
      when "register_book_review"
        if record["user_fbconnect_id"]
          Review.create_or_update_from_ios_client_data(record)
        else
          AnonymousReview.create_or_update_from_ios_client_data(record)
        end
      # stands for creating and updating the highlight
      when "register_book_highlight"
        if record["user_fbconnect_id"]
          result = BookHighlight.create_or_update_from_ios_client_data(record)
        else
          result = AnonymousBookHighlight.create_or_update_from_ios_client_data(record)
        end
        
        # if we've created a new record, we return the associated Web API answer
        if result.is_a?(BookHighlight) || result.is_a?(AnonymousBookHighlight)
          response = result.response_when_created_via_web_api(:source_app => record["apple_id"])
        end
      when "register_ios_user"
        Login.register_from_ios_app(record)
      when "update_book_description"
        Book.update_description_from_web_api(record)
      end
    end
    
    # only when archiving the incoming data is important (when the API is not stable)
    # self.update_attributes(:processed => true)
    # in production environment we don't want to keep an incoming data archive
    self.destroy
    
    return response
  end
  
end
