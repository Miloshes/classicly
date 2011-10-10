class BookDeliveryPackage < ActiveRecord::Base
  belongs_to :source_user, :class_name => "Login"
  belongs_to :destination_user, :class_name => "Login"
  
  belongs_to :deliverable, :polymorphic => true
  
  validates :source_user, :presence => true
  validates :destination_user, :presence => true
  validates :deliverable, :presence => true
  
  def create_from_web_api_call(data)
    # book = Book.find(data["book_id"].to_i)
    # 
    # if book.blank? || data["user_fbconnect_id"].blank? || data["device_ss_id"].blank?
    #   return nil
    # end
    # 
    # login = Login.where(:fb_connect_id => data["user_fbconnect_id"].to_s).first()
    # 
    # # a fallback - we have facebook data but the user login hasn't been created, we're storing stuff as anonymous highlight
    # if login.blank?
    #   # for this to work "device_id" is a must parameter for the call
    #   AnonymousBookHighlight.create_or_update_from_ios_client_data(data)
    #   return
    # end
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
