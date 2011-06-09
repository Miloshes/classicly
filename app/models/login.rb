class Login < ActiveRecord::Base
  has_many :reviews
  
  def self.register_from_ios_app(params)
    params.stringify_keys!
    
    # avoid double registration
    if params['user_fbconnect_id']
      return true if Login.where(:fb_connect_id => params['user_fbconnect_id']).exists?
    end
    
    new_login = Login.create(
      :fb_connect_id    => params['user_fbconnect_id'],
      :ios_device_id    => params['device_id'],
      :email            => params['user_email'],
      :first_name       => params['user_first_name'],
      :last_name        => params['user_last_name'],
      :location_city    => params['user_location_city'],
      :location_country => params['user_location_country']
    )
    
    # migrate the anonymous reviews as we have the facebook information now
    if params['structure_version'] == '1.2'
      AnonymousReview.where(:ios_device_id => new_login.ios_device_id).each do |anonymous_review|
        new_review = Review.create(
            :reviewer      => new_login,
            :fb_connect_id => new_login.fb_connect_id,
            :reviewable    => anonymous_review.reviewable,
            :content       => anonymous_review.content,
            :rating        => anonymous_review.rating,
            :created_at    => anonymous_review.created_at
          )
          
        anonymous_review.destroy if new_review
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
