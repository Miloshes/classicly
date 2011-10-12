class Login < ActiveRecord::Base
  has_many  :reviews
  has_many  :highlight_notes
  has_one   :library


  def self.register_from_ios_app(params)
    params.stringify_keys!

    # required parameter
    return true if params['user_fbconnect_id'].blank?

    existing_login = Login.where(:fb_connect_id => params['user_fbconnect_id']).first()

    # avoid double registration for APIs older than 1.2 (user registration call happens before every register review call)
    if params['structure_version'] != '1.2'
      return true if existing_login
    end

    if existing_login
      login = existing_login

      # migrate existing logins to the new device_ss_id
      if params['device_ss_id'] && login.ios_device_ss_id.blank?
        login.update_attributes(:ios_device_ss_id => params['device_ss_id'])
      end
    else
      login = Login.create(
        :fb_connect_id    => params['user_fbconnect_id'],
        :ios_device_id    => params['device_id'],
        :ios_device_ss_id => params['device_ss_id'],
        :email            => params['user_email'],
        :first_name       => params['user_first_name'],
        :last_name        => params['user_last_name'],
        :location_city    => params['user_location_city'],
        :location_country => params['user_location_country']
      )
    end

    # migrate the anonymous reviews and highlights as we have the facebook information now
    if params['structure_version'] == '1.2'
      login.convert_anonymous_reviews_into_normal_ones
      login.convert_anonymous_book_highlights_into_normal_ones
    end

  end

  def self.register_from_classicly(user_profile = {})
    user_profile.stringify_keys!
    is_new_login  = !Login.exists?(:fb_connect_id => user_profile['id'])
    login         = Login.find_or_create_by_fb_connect_id(user_profile['id'])
    city, country = user_profile['location'] ? user_profile['location']['name'].split(',') : [ "", ""]


    login.attributes=  { :email => user_profile['email'],
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
    AnonymousReview.where(:ios_device_id => self.ios_device_id).all().each do |anonymous_review|
      anonymous_review.convert_to_normal_review
    end
  end

  def convert_anonymous_book_highlights_into_normal_ones
    AnonymousBookHighlight.where(:ios_device_ss_id => self.ios_device_ss_id).all().each do |anonymous_book_highlight|
      anonymous_book_highlight.convert_to_normal_highlight
    end
  end


  def send_registration_notification
    LoginMailer.registration_notification(self).deliver
  end

end
