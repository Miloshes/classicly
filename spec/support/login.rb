Factory.define :login do|f|
  f.first_name 'Zsolt'
  f.last_name 'Maslanyi'
  f.email 'zsolt.maslanyi@gmail.com'

  f.updated_at Time.now
  f.location_city 'Budapest'
  f.location_country 'Hungary'
  f.fb_connect_id '123456'
  f.is_admin true
  f.ios_device_id 'ASDASD123'
end
