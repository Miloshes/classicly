class Login < ActiveRecord::Base
  has_many :reviews
  has_one :library
  
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
    else
      login = Login.create(
        :fb_connect_id    => params['user_fbconnect_id'],
        :ios_device_id    => params['device_id'],
        :email            => params['user_email'],
        :first_name       => params['user_first_name'],
        :last_name        => params['user_last_name'],
        :location_city    => params['user_location_city'],
        :location_country => params['user_location_country']
      )
    end
    
    # migrate the anonymous reviews as we have the facebook information now
    if params['structure_version'] == '1.2'
      AnonymousReview.where(:ios_device_id => login.ios_device_id).each do |anonymous_review|
        anonymous_review.convert_to_normal_review
      end
    end

  end

  def self.register_from_classicly user_profile = {}
    user_profile.stringify_keys!

    login        = Login.find_by_fb_connect_id user_profile['id']
    is_new_login = false

    unless login
      city, country = user_profile['location']['name'].split(', ')

      login = Login.create(
          :fb_connect_id    => user_profile['id'],
          :email            => user_profile['email'],
          :first_name       => user_profile['first_name'],
          :last_name        => user_profile['last_name'],
          :location_city    => city,
          :location_country => country
        )

      is_new_login = true
    end

    login.performable_log_session_opened if Rails.env.production?

    return login, is_new_login
  end
  
  def not_registered_with_facebook?
    return self.fb_connect_id.null?
  end

  def report_successful_registration_to_performable
    Net::HTTP.get(URI.parse("http://analytics.performable.com/v1/event?_n=3F6mY45twfux&_a=0HuiG9&_i=#{self.fb_connect_id}"))
  end
  
  def performable_log_session_opened
    Net::HTTP.get(URI.parse("http://analytics.performable.com/v1/event?_n=7DjavS9rK42m&_a=0HuiG9&_i=#{self.fb_connect_id}"))
  end
end
