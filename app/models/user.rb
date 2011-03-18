class User < ActiveRecord::Base
  has_many :logins
  has_many :reviews

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  def apply_omniauth(omniauth)
    logins.build(:provider => omniauth['provider'], :uid => omniauth['uid'], :image_url => omniauth['user_info']['image'])
    self.email = omniauth['extra']['user_hash']['email']
  end
  
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
