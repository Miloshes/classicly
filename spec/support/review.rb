Factory.define :review do |f|
  f.fb_connect_id "123456"
  f.reviewer
  f.reviewable
  f.created_at Time.now
  f.content "Review text comes here"
  f.rating 3
end