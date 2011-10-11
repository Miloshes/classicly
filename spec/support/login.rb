FactoryGirl.define do
  
  factory :login, :aliases => [:user] do
    first_name "Zsolt"
    last_name "Maslanyi"
    email "zsolt.maslanyi@gmail.com"
    is_admin false
    
    updated_at Time.now
    
    location_city "Budapest"
    location_country "Hungary"
    fb_connect_id "123456"
    
    ios_devices { |ios_devices| [ios_devices.association(:ios_device), ios_devices.association(:ios_device)] }
  end
  
end
