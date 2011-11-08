# Model to temporary hold and then process incoming data that's coming from our iOS client apps
class IncomingData < ActiveRecord::Base
  validates :json_data, :presence => true

  # Note:
  # Incoming data should have an action field to describe what to do with the data (easily extensible)
  # Note #2:
  # We're returning JSON answers most of the cases, except for the old versions of the API (before 1.2)
  def process!
    return true if self.processed
    
    parsed_data = ActiveSupport::JSON.decode(self.json_data)

    # setting the general response, the sub-tasks can override it
    # NOTE: upwards from API v1.3, we're always sending back proper JSON as a response
    if parsed_data.is_a?(Hash) && parsed_data["structure_version"] == "1.3"
    # TODO: API >= 1.3
      response = {"general_response" => "SUCCESS"}.to_json
    else
      response = "SUCCESS"
    end

    # if we're dealing with 1 data record and not an array, convert to array
    if parsed_data.is_a? Hash
      parsed_data = [parsed_data]
    end
    
    parsed_data.each do |record|
      case record["action"]
      # stands for creating and updating
      when "register_book_review"
        if record["user_fbconnect_id"] || record["user_email"]
          Review.create_or_update_from_ios_client_data(record)
        else
          AnonymousReview.create_or_update_from_ios_client_data(record)
        end
        
        # TODO: API >= 1.3
        if record["structure_version"] == "1.3"
          response = {"general_response" => "SUCCESS"}.to_json
        else
          response = "SUCCESS"
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
        # upwards from API v1.3 we care about the response
        # TODO: API >= 1.3
        if record["structure_version"] == "1.3"
          new_login = Login.register_from_ios_app(record)
          
          if new_login
            response = new_login.response_for_web_api(record)
          else
            # we were trying to re-register an existing full account
            response = {"general_response" => "FAILURE"}.to_json
          end
        else
          Login.register_from_ios_app(record)
        end
      when "login_ios_user"
        logged_in_user = Login.authenticate(record["user_email"], record["password"])
        
        if logged_in_user
          response = logged_in_user.response_for_web_api(record)
        else
          response = {"general_response" => "FAILURE"}.to_json
        end
      when "update_book_description"
        Book.update_description_from_web_api(record)
      when "send_book_from_user_to_user"
        response = BookDeliveryPackage.register_from_ios_app(record)
      end
    end
    
    # only when archiving the incoming data is important (when the API is not stable)
    # self.update_attributes(:processed => true)
    # in production environment we don't want to keep an incoming data archive
    self.destroy
    
    return response
  end
  
end
