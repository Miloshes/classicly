Fabricator(:login) do
  first_name "Zsolt"
  last_name "Maslanyi"
  email "zsolt.maslanyi@gmail.com"
  
  updated_at Time.now
  location_city "Budapest"
  location_country "Hungary"
  fb_connect_id "123456"
  is_admin true
  ios_device_id "ASDASD123"
end