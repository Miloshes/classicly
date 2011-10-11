FactoryGirl.define do
  
  factory :ios_device do
    sequence(:original_udid) { |n| "orignal_udid#{n}" }
    sequence(:ss_id) { |n| "ss_id#{n}" }
  end
  
end