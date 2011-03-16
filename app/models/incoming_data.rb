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

    parsed_data.each do |record|
      case record['action']
      when 'create_book_review'
        Review.create_from_ios_client_data(record)
      end
    end
    
    # only when archiving the incoming data is important (when the API is not stable)
    self.update_attributes(:processed => true)
    # in production environment we don't want to keep an incoming data archive
    # self.destroy
  end
end
