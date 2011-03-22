class Login < ActiveRecord::Base
  has_many :reviews
  
  def self.register_from_ios_app(params)
    params.stringify_keys!
        
    return true if Login.where(:uid => params['user_fbconnect_id']).exists?
    
    Login.create(
        :uid              => params['user_fbconnect_id'],
        :provider         => 'facebook',
        :email            => params['user_email'],
        :first_name       => params['user_first_name'],
        :last_name        => params['user_last_name'],
        :location_state   => params['user_location_state'],
        :location_city    => params['user_location_city'],
        :location_country => params['user_location_country']
      )
  end

end
