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
  
  def self.register_from_classicly(params)
    login = Login.find_by_fb_connect_id(params[:uid])
    unless login
      login = Login.create(:fb_connect_id => params[:uid], :first_name => params[:first_name], :last_name => params[:last_name],
              :email => params[:email], :location_city => params[:city], :location_state => params[:state],
              :location_country => params[:country])
    end
    login
  end

end
