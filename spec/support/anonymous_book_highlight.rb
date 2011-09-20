Factory.define :anonymous_book_highlight do |f|
  f.first_character 1
  f.last_character 29
  f.content "The rabbit went down the hole."
  f.ios_device_id "asd"  
  f.created_at Time.now
  f.book
  f.origin_comment "user comment comes here"
end