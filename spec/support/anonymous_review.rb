FactoryGirl.define do

  factory :anonymous_review do
    association :reviewable, :factory => :book
    content "review content"
    rating 3
    created_at Time.now
    ios_device_id "ASDASD"
  end

end