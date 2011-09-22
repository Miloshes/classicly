class BookHighlight < ActiveRecord::Base
  belongs_to :book
  belongs_to :user, :class_name => 'Login', :foreign_key => 'login_id'
  
  validates :first_character, :presence => true
  validates :last_character, :presence => true
  validates :book, :presence => true
  
  # highlights are tied to registered users. Highlights from unregistered users are saved as AnonymousBookHighlight
  validates :user, :presence => true
  validates :fb_connect_id, :presence => true
  
  scope :all_for_book_and_user, lambda { |book, user| where(:book => book, :user => user) }
  
  def self.create_or_update_from_ios_client_data(data)
    book = Book.find(data["book_id"].to_i)

    if book.blank? || data["user_fbconnect_id"].blank? || data["device_id"].blank?
      return nil
    end
    
    login = Login.where(:fb_connect_id => data["user_fbconnect_id"].to_s).first()

    # a fallback - we have facebook data but the user login hasn't been created, we're storing stuff as anonymous highlight
    if login.blank?
      # for this to work "device_id" is a must parameter for the call
      AnonymousBookHighlight.create_or_update_from_ios_client_data(data)
      return
    end
    
    new_timestamp = Time.parse(data["timestamp"])
    
    highlight_conditions = {
        :user            => login,
        :fb_connect_id   => login.fb_connect_id,
        :book            => book,
        :content         => data["content"],
        :first_character => data["first_character"],
        :last_character  => data["last_character"]
      }

    new_highlight_data = {
        :created_at     => new_timestamp,
        :origin_comment => data["origin_comment"]
      }
  
    highlight = self.where(highlight_conditions).first()
  
    if highlight
      highlight.update_attributes(new_highlight_data) unless new_timestamp < highlight.created_at
    else
      self.create(highlight_conditions.merge new_highlight_data)
    end
  end
  
end
