FactoryGirl.define do
  
  factory :review do
    association :reviewer, :factory => :login
    association :reviewable, :factory => :book
    
    fb_connect_id { reviewer.fb_connect_id }
    
    created_at Time.now
    content "Review text comes here"
    rating 3
  end
  
end
