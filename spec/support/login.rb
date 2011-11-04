FactoryGirl.define do
  
  factory :login, :aliases => [:user] do
    first_name "Zsolt"
    last_name "Maslanyi"
    email { "#{first_name.downcase}@gmail.com" }
    is_admin false
    
    updated_at Time.now
    
    location_city "Budapest"
    location_country "Hungary"
    
    sequence(:fb_connect_id) { |n| "fb_id_#{n}" }
    
    ios_devices { |ios_devices| [ios_devices.association(:ios_device), ios_devices.association(:ios_device)] }
  end
  
end
