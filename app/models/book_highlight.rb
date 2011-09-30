class BookHighlight < ActiveRecord::Base
  # we have to be able to handle URLs in the model
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers
  include CommonSeoDefaultsMethods
  
  belongs_to :book
  belongs_to :user, :class_name => 'Login', :foreign_key => 'login_id'
  
  validates :first_character, :presence => true
  validates :last_character, :presence => true
  validates :book, :presence => true
  validates :content, :presence => true
  
  # highlights are tied to registered users. Highlights from unregistered users are saved as AnonymousBookHighlight
  validates :user, :presence => true
  validates :fb_connect_id, :presence => true
  
  has_friendly_id :content, :use_slug => true, :strip_non_ascii => true
  
  scope :all_for_book_and_user, lambda { |book, user| where(:book => book, :user => user) }
  
  def self.create_or_update_from_ios_client_data(data)
    book = Book.find(data["book_id"].to_i)

    if book.blank? || data["user_fbconnect_id"].blank? || data["device_ss_id"].blank?
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
  
end
