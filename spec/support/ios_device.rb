FactoryGirl.define do
  
  factory :ios_device do
    sequence(:original_udid) { |n| "orignal_udid#{n}" }
    sequence(:ss_udid) { |n| "ss_udid#{n}" }
  end
  
end