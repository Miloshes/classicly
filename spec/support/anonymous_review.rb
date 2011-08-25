Factory.define :anonymous_review do |f|
  f.reviewable
  f.content "review content"
  f.rating 3
  f.created_at Time.now
  f.ios_device_id "ASDASD"
end