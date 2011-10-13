class IosDevice < ActiveRecord::Base
  belongs_to :user, :class_name => "Login"
  
  # our spreadsong id for the device, generated from the original UDID which we can't use anymore
  validates :ss_udid, :presence => true
end
