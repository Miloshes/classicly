FactoryGirl.define do
  factory :anonymous_book_highlight do
    ios_device_id "asd"
    created_at Time.now
    book
    first_character 0
    last_character 29
    content "The rabbit went down the hole."
  
    trait :has_note do
      origin_comment "Here's my note."
    end
  
    factory :anonymous_book_highlight_with_note, :traits => [:has_note]
  end
end