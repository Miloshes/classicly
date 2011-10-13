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

    # required parameter
    return true if params['user_fbconnect_id'].blank?

    existing_login = Login.where(:fb_connect_id => params['user_fbconnect_id']).first()

    # avoid double registration for APIs older than 1.2 (user registration call happens before every register review call)
    if !["1.2", "1.3"].include?(params["structure_version"])
      return true if existing_login
    end

    if existing_login
      login = existing_login
      login.try_to_migrate_device_udids(params["device_id"], params["device_ss_id"])
    else
      login = Login.create(
        :fb_connect_id    => params['user_fbconnect_id'],
        # :ios_device_id    => params['device_id'],
        # :ios_device_ss_id => params['device_ss_id'],
        :email            => params['user_email'],
        :first_name       => params['user_first_name'],
        :last_name        => params['user_last_name'],
        :location_city    => params['user_location_city'],
        :location_country => params['user_location_country']
      )
    end

    # migrate the anonymous reviews and highlights as we have the facebook information now
    if ["1.2", "1.3"].include?(params["structure_version"])
      login.convert_anonymous_reviews_into_normal_ones
      login.convert_anonymous_book_highlights_into_normal_ones
    end

  end

  def self.register_from_classicly(user_profile = {})
    user_profile.stringify_keys!
    is_new_login  = !Login.exists?(:fb_connect_id => user_profile['id'])
    login         = Login.find_or_create_by_fb_connect_id(user_profile['id'])
    city, country = user_profile['location'] ? user_profile['location']['name'].split(',') : ["", ""]


    login.attributes = { :email => user_profile['email'],
      :first_name       => user_profile['first_name'],
      :last_name        => user_profile['last_name'],
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

  def send_registration_notification
    LoginMailer.registration_notification(self).deliver
  end
  
  # Tries to migrate the iOS devices that belongs to this login to use the new UDID
  def try_to_migrate_device_udids(original_udid, new_ss_udid)
    return nil if (original_udid.blank? || new_ss_udid.blank?)

    ios_device = self.ios_devices.where(:original_udid => original_udid).first()
    
    if ios_device
      ios_device.update_attributes(:ss_udid => new_ss_udid)
    end
  end
  
end
