class Login < ActiveRecord::Base
  has_many :reviews
  
  def self.register_from_ios_app(params)
    params.stringify_keys!
        
    return true if Login.where(:fb_connect_id => params['user_fbconnect_id']).exists?
    
    Login.create(
        :fb_connect_id    => params['user_fbconnect_id'],
        :email            => params['user_email'],
        :first_name       => params['user_first_name'],
        :last_name        => params['user_last_name'],
        :location_city    => params['user_location_city'],
        :location_country => params['user_location_country']
      )
  end
  
  def self.register_from_classicly(params, mixpanel)
    login = Login.find_by_fb_connect_id(params[:uid])
    unless login
      login = Login.create(:fb_connect_id => params[:uid], :first_name => params[:first_name], :last_name => params[:last_name],
              :email => params[:email], :location_city => params[:city], :location_country => params[:country])
      mixpanel.track_event("signup", {:id => login.fb_connect_id})
    end
    login
  end

  def report_successful_registration_to_performable
    Net::HTTP.get(URI.parse("http://analytics.performable.com/v1/event?_n=3F6mY45twfux&_a=0HuiG9&_i=#{self.fb_connect_id}"))
  end
end
