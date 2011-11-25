class IosDevice < ActiveRecord::Base
  belongs_to :user, :class_name => "Login"
  
  # our spreadsong id for the device, generated from the original UDID which we can't use anymore
  validates :ss_udid, :presence => true
  
  def self.make_sure_its_registered_and_assigned_to_user(original_udid, new_ss_udid, user)
    return nil if (original_udid.blank? && new_ss_udid.blank?) || user.blank?
    
    ios_device = nil
    
    if new_ss_udid
      ios_device = IosDevice.where(:ss_udid => new_ss_udid).first()
    end
    
    if ios_device.blank? && original_udid
      ios_device = IosDevice.where(:original_udid => original_udid).first()
    end
    
    result = false
    
    # == the device wasn't registered, register it for this user
    if ios_device.blank?
      new_device = IosDevice.create(:original_udid => original_udid, :ss_udid => new_ss_udid, :user => user)
      
      result = new_device if new_device.valid?
    else
    # == re-assign the existing device if it belongs to another user
      if ios_device.user != user
        ios_device.update_attributes(:user => user)
      end
      
      result = ios_device
    end
    
    return result
  end
  
  # Tries to migrate an iOS device that belongs to this login to use the new UDID
  def self.try_to_migrate_device_udids(original_udid, new_ss_udid)
    return nil if (original_udid.blank? || new_ss_udid.blank?)

    ios_device = nil

    if original_udid
      ios_device = IosDevice.where(:original_udid => original_udid).first()
    end
    
    if ios_device
      ios_device.update_attributes(:ss_udid => new_ss_udid)
    end
  end
  
end
