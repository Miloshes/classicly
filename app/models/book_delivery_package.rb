class BookDeliveryPackage < ActiveRecord::Base
  belongs_to :source_user, :class_name => "Login"
  belongs_to :destination_user, :class_name => "Login"
  
  belongs_to :deliverable, :polymorphic => true
  
  validates :source_user, :presence => true
  validates :destination_user, :presence => true
  validates :deliverable, :presence => true
  
  def self.create_from_web_api_call(data)
    # == check the required parameters
    
    required_parameters = ["structure_version", "book_type", "source_user_email", "destination_user_email"]
    
    case data["book_type"]
    when "classic"
      required_parameters << "book_id"
    when "user_uploaded"
      required_parameters << "book_data"
    end
    
    required_parameters.each do |param_to_check|
      return nil if data[param_to_check].blank?
    end
    
    source_user      = Login.find_by_email(data["source_user_email"])
    destination_user = Login.find_by_email(data["destination_user_email"])

    return nil if source_user.blank? || destination_user.blank?
    
    case data["book_type"]
    when "classic"
      deliverable = Book.find_by_id(data["book_id"])
    when "user_uploaded"
      # TODO: pass the book_data!
      deliverable = UserUploadedContent.create
    end
    
    package_conditions = {
      :source_user      => source_user,
      :destination_user => destination_user,
      :deliverable      => deliverable
    }
    
    new_package_data = {
      :message => data["message"]
    }
    
    result = false
    
    book_delivery_package = self.where(package_conditions).first()
    
    if book_delivery_package
      result = book_delivery_package
    else
      # puts "\nCalling it with: #{(package_conditions.merge new_package_data).inspect}\n"
      
      new_package = self.create(package_conditions.merge new_package_data)
      
      result = new_package if new_package.valid?
    end
    
    # puts "\n\nRESULT: #{result.reload.inspect}\n\n"
    
    return result

    # 
    # new_timestamp = Time.parse(data["timestamp"])
    # 
    # highlight_conditions = {
    #     :user            => login,
    #     :fb_connect_id   => login.fb_connect_id,
    #     :book            => book,
    #     :content         => data["content"],
    #     :first_character => data["first_character"],
    #     :last_character  => data["last_character"]
    #   }
    # 
    # new_highlight_data = {
    #     :created_at     => new_timestamp,
    #     :origin_comment => data["origin_comment"]
    #   }
    #   
    # highlight = self.where(highlight_conditions).first()
    # 
    # result = false
    #   
    # if highlight
    #   highlight.update_attributes(new_highlight_data) unless new_timestamp < highlight.created_at
    #   
    #   result = highlight
    # else
    #   new_highlight = self.create(highlight_conditions.merge new_highlight_data)
    #   
    #   result = new_highlight if new_highlight.valid?
    # end
    # 
    # return result
    # 
  end
  
end
