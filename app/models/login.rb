class Login < ActiveRecord::Base
  has_many :reviews
  
  # code paths:
  # API v 1.1
  #  - login exists with fb_connect_id, exit
  #  - login doesn't exists with fb_connect_id, register with all the params
  # API v 1.2
  #  - no fb_connect_id in params, just device_id
  #    - already exists, exit
  #    - doesn't exists, create it
  #  - fb_connect_id and device_id
  #    - already exists, exit
  #    - doesn't exists, update the login and the associated reviews with the FB info
  def self.register_from_ios_app(params)
    params.stringify_keys!
    
    # avoid double registration - works for API version 1.1 and 1.2
    if params['user_fbconnect_id']
      return true if Login.where(:fb_connect_id => params['user_fbconnect_id']).exists?
    else
      return true if Login.where(:ios_device_id => params['device_id']).exists?
    end
    
    # API 1.1 and older
    if params['structure_version'] != '1.2'
      
      new_login = Login.create(
        :fb_connect_id    => params['user_fbconnect_id'],
        :email            => params['user_email'],
        :first_name       => params['user_first_name'],
        :last_name        => params['user_last_name'],
        :location_city    => params['user_location_city'],
        :location_country => params['user_location_country']
      )
      
      Rails.logger.info(" API 1.1 (or older): created new login with FBConnect data")
    
    else
      # API 1.2
      
      if params['user_fbconnect_id'].blank?
        new_login = Login.create(:ios_device_id => params['device_id'])
        
        Rails.logger.info(" API 1.2: created new login with device ID")
      else
        login_to_update = Login.where(:ios_device_id => params['device_id']).first()
        login_to_update.update_attributes(
          :fb_connect_id    => params['user_fbconnect_id'],
          :email            => params['user_email'],
          :first_name       => params['user_first_name'],
          :last_name        => params['user_last_name'],
          :location_city    => params['user_location_city'],
          :location_country => params['user_location_country']
        )
        
        login_to_update.reviews.find_each do |review|
          review.update_attributes(:fb_connect_id => login_to_update.fb_connect_id)
        end
        
        Rails.logger.info(" API 1.2: existing login, updating with FBConnect data and migrating reviews")
      end
    
    end
    
  end
    
  def self.register_from_classicly(profile, location, mix_panel)
    login = Login.find_by_fb_connect_id profile['id']
    is_new = false
    unless login
      login = Login.create(:fb_connect_id => profile['id'], :first_name => profile['first_name'],
        :last_name => profile['last_name'],:email => profile['email'], :location_city => location[:city],
        :location_country => location[:country])
      if Rails.env.production?
        mix_panel.track_event("Facebook Register", {:id => login.fb_connect_id})
        login.report_successful_registration_to_performable  
      end
      is_new = true
    end
    login.performable_log_session_opened if Rails.env.production?
    is_new
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
