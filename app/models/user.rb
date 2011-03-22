class User < ActiveRecord::Base
  has_many :logins
  has_many :reviews


  
  def password_required?
    false
  end
  
  def login_for(provider)
    self.logins.where(:provider => provider.to_s).first
  end

  def uid_for(provider)
    self.logins.where(:provider => provider.to_s).first.uid
  end
end
