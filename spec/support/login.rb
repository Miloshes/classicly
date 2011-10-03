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
    
    ios_device_id "asd"
    ios_device_ss_id "asd2"
  end
  
end
