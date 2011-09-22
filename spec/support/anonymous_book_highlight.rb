FactoryGirl.define do
  factory :anonymous_book_highlight do
    first_character 1
    last_character 1
    ios_device_id "asd"
    created_at Time.now
    book
  
    trait :has_highlight do
      first_character 0
      last_character 29
      content "The rabbit went down the hole."
    end
  
    trait :has_note do
      origin_comment "Here's my note."
    end
  
    factory :anonymous_highlight_with_note, :traits => [:has_highlight, :has_note]
    factory :anonymous_highlight_just_note, :traits => [:has_note]
  end
end