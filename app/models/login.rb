class Login < ActiveRecord::Base
  has_many :reviews
  has_many :ios_devices, :foreign_key => "user_id"
  has_one :library
  
  # Just an alias for ios_devices.first. Makes total sense as most of our users will only have one device.
  def ios_device
    self.ios_devices.first
  end
  
  def self.register_from_ios_app(params)
    params.stringify_keys!

    # required parameters
    
    required_parameters = ["structure_version"]
    # NOTE: API version < v1.3
    if params["structure_version"] != "1.3"
      required_parameters << "user_fbconnect_id"
    end
    
    required_parameters.each do |param_to_check|
      return nil if params[param_to_check].blank?
    end

    # upwards from API v1.3, we use the email as the main identification method
    if params["structure_version"] == "1.3"
      existing_login = Login.where(:email => params["user_email"]).first()
    else
      existing_login = Login.where(:fb_connect_id => params["user_fbconnect_id"]).first()
    end

    # avoid double registration for APIs older than 1.2 (user registration call happens before every register review call)
    if !["1.2", "1.3"].include?(params["structure_version"])
      return true if existing_login
    end

    if existing_login
      
      if params["structure_version"] == "1.3"
        # it's an existing half-account, migrate it into a full one
        if existing_login.not_a_real_account
          existing_login.turn_account_into_a_real_one(params)
        else
          # it's an existing full-account, have to respond with failure
          # (shouldn't re-register previous accounts)
          return nil
        end
      end
      
      login = existing_login
    else
      login = Login.create(
        :fb_connect_id    => params["user_fbconnect_id"],
        :twitter_name     => params["twitter_name"],
        :email            => params["user_email"],
        :first_name       => params["user_first_name"],
        :last_name        => params["user_last_name"],
        
        :location_city    => params["user_location_city"],
        :location_country => params["user_location_country"],
        
        :terms_of_service => params["terms_of_service"] == "accepted",
        :password         => params["password"]
      )
    end
    
    login.manage_associated_ios_devices(params)

    # migrate the anonymous reviews and highlights as we have the facebook information now
    if ["1.2", "1.3"].include?(params["structure_version"])
      login.convert_anonymous_reviews_into_normal_ones
      login.convert_anonymous_book_highlights_into_normal_ones
    end
    
    return login
  end
  
  def response_for_web_api(params)
    # our response to register_from_ios_app and login_ios_user Web API call
    
    # upwards from API v1.3, we care about the return value
    return nil if !params["structure_version"] == "1.3"

    response = {}
    fields_to_return = %w(email fb_connect_id first_name last_name location_city location_country twitter_name)
        
    fields_to_return.each { |field| response[field] = self.send(field) }
    
    return response.to_json
  end

  def self.register_from_classicly(user_profile = {})
    user_profile.stringify_keys!
    is_new_login  = !Login.exists?(:fb_connect_id => user_profile["id"])
    login         = Login.find_or_create_by_fb_connect_id(user_profile["id"])
    city, country = user_profile["location"] ? user_profile["location"]["name"].split(",") : ["", ""]


    login.attributes = {
      :email            => user_profile["email"],
      :first_name       => user_profile["first_name"],
      :last_name        => user_profile["last_name"],
      :location_city    => city,
      :location_country => country
    }

    # set the access token for the user, we will need it if the user wants to be removed from the mailing list
    login.access_token = ActiveSupport::SecureRandom.base64(8).gsub("/","_").gsub(/=+$/,"") if login.access_token.nil?

    login.save

    # send mail
    login.send_registration_notification if is_new_login

    return login, is_new_login
  end

  def name
    self.first_name + " " + self.last_name
  end
  
  def not_registered_with_facebook?
    return self.fb_connect_id.null?
  end

  # == For converting anonymous resources belonging to the user, identified by the user's iOS device into normal ones

  def convert_anonymous_reviews_into_normal_ones
    # == convert reviews with old UDIDs
    original_udids = self.ios_devices.collect(&:original_udid)

    AnonymousReview.where("ios_device_id IN (?)", original_udids).find_each do |anonymous_review|
      anonymous_review.convert_to_normal_review
    end
    
    # == convert reviews with new UDIDs
    ss_udids = self.ios_devices.collect(&:ss_udid)

    AnonymousReview.where("ios_device_ss_id IN (?)", ss_udids).find_each do |anonymous_review|
      anonymous_review.convert_to_normal_review
    end
  end

  def convert_anonymous_book_highlights_into_normal_ones
    # == convert reviews with new UDIDs
    ss_udids = self.ios_devices.collect(&:ss_udid)
    
    # NOTE: book highlights were introduced when we were already using the new
    AnonymousBookHighlight.where("ios_device_ss_id IN (?)", ss_udids).all().each do |anonymous_book_highlight|
      anonymous_book_highlight.convert_to_normal_highlight
    end
  end
  
  # == Security related methods
  
  def password
    @password
  end
  
  def password=(new_password)
    return nil if new_password.blank?
    
    @password = new_password
    create_new_salt
    self.hashed_password = Login.encrypted_password(self.password, self.salt)
  end
  
  def self.authenticate(email, password)
    login = self.find_by_email(email)
    if login
      expected_password = Login.encrypted_password(password, login.salt)
      login = nil if expected_password != login.hashed_password
    end
    login
  end
    
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble-wobble-heres-the-trouble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  private :create_new_salt
  
  # == Utility methods
  
  def send_registration_notification
    LoginMailer.registration_notification(self).deliver
  end
  
  def manage_associated_ios_devices(params)
    IosDevice.make_sure_its_registered_and_assigned_to_user(params["device_id"], params["device_ss_id"], self)
    IosDevice.try_to_migrate_device_udids(params["device_id"], params["device_ss_id"])
  end
  
  # == Account related
  
  # marks when this Classicly account is still just a Facebook login without a password
  def not_a_real_account
    self.hashed_password.blank?
  end

  def turn_account_into_a_real_one(params)
    self.update_attributes(
      :terms_of_service => params["terms_of_service"] == "accepted",
      :password         => params["password"]
    )
  end
  
end
