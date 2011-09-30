class AnonymousBookHighlight < ActiveRecord::Base
  # we have to be able to handle URLs in the model
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers
  include CommonSeoDefaultsMethods
  
  belongs_to :book
  
  validates :first_character, :presence => true
  validates :last_character, :presence => true
  validates :book, :presence => true
  validates :content, :presence => true
  
  # we tie anonymous highlights to device IDs, so we can attach them to the user when he registers
  validates :ios_device_ss_id, :presence => true
  
  has_friendly_id :content, :use_slug => true, :strip_non_ascii => true
  
  scope :all_for_book_and_ios_device, lambda { |book, ios_device_ss_id|
    where(:book => book, :ios_device_ss_id => ios_device_ss_id)
  }
  
  def self.create_or_update_from_ios_client_data(data)
    book = Book.find(data["book_id"].to_i)

    return nil if book.blank?
    
    new_timestamp = Time.parse(data["timestamp"])
  
    highlight_conditions = {
        :ios_device_ss_id => data["device_ss_id"],
        :book             => book,
        :content          => data["content"],
        :first_character  => data["first_character"],
        :last_character   => data["last_character"]
      }

    new_highlight_data = {
        :created_at     => new_timestamp,
        :origin_comment => data["origin_comment"]
      }
  
    highlight = self.where(highlight_conditions).first()

    result = false
    
    if highlight
      highlight.update_attributes(new_highlight_data) unless new_timestamp < highlight.created_at
      
      result = highlight
    else
      new_highlight = self.create(highlight_conditions.merge new_highlight_data)

      result = new_highlight if new_highlight.valid?
    end
    
    return result
  end
  
  def response_when_created_via_web_api(params)
    # our response to highlight creation Web API call
    # - the URL for the highlight's landing page
    # - the share text for Twitter
    # - the share text for Facebook
    
    share_message_handler = ShareMessageHandler.new
    twitter_message       = share_message_handler.get_message_for(
        :target_platform => "twitter",
        :message_type    => "highlight share",
        :book            => self.book,
        :highlight       => self,
        :apple_id        => params[:source_app]
      )
    facebook_message      = share_message_handler.get_message_for(
        :target_platform => "facebook",
        :message_type    => "highlight share",
        :book            => self.book,
        :highlight       => self,
        :apple_id        => params[:source_app]
      )
    
    return {
      :public_highlight_url => self.public_url,
      :twitter_message      => twitter_message,
      :facebook_message     => facebook_message
    }.to_json
  end
  
  def public_url
    default_url_options[:host] = "www.classicly.com"
    default_url_options[:host] = "classicly-staging.heroku.com" if Rails.env.staging?
    
    author_book_highlight_url(self.book.author.cached_slug, self.book.cached_slug, self.cached_slug)
  end
  
  def convert_to_normal_highlight
    login = Login.where(:ios_device_ss_id => self.ios_device_ss_id).first()
    # NOTE: while we're migrating away from using the UDID as the device_id
    if login.blank?
      login = Login.where(:ios_device_id => self.ios_device_id).first()
    end
    
    highlight_conditions = {
      :user            => login,
      :book            => self.book,
      :fb_connect_id   => login.fb_connect_id,
      :first_character => self.first_character,
      :last_character  => self.last_character,
    }

    existing_highlight = BookHighlight.where(highlight_conditions).first()
    
    highlight_data = {
      :content        => self.content,
      :origin_comment => self.origin_comment
    }
        
    if existing_highlight
      successful_update = existing_highlight.update_attributes(highlight_data)
      
      self.destroy if successful_update
    else
      new_highlight = BookHighlight.create(highlight_conditions.merge highlight_data)
      
      self.destroy if new_highlight.valid?
    end
  end
  
end
