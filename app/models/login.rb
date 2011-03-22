class Login < ActiveRecord::Base
  has_many :reviews
  
  def self.find_or_new_login_api(uid, first_name, last_name, email, city, state, country)
    login = find_by_uid(uid)
    unless login
      login = Login.create(:location_city => city, :location_country => country, :uid => uid, :last_name => last_name, :location_state => state, :email => :email, :first_name => first_name)
    end
    login
  end

end
