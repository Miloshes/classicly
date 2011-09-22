FactoryGirl.define do
  factory :book_highlight do
    first_character 1
    last_character 1
    created_at Time.now
    book
    user
    fb_connect_id { user.fb_connect_id }

    trait :has_highlight do
      first_character 0
      last_character 29
      content "The rabbit went down the hole."
    end

    trait :has_note do
      origin_comment "Here's my note."
    end

    factory :highlight_with_note, :traits => [:has_highlight, :has_note]
    factory :highlight_just_note, :traits => [:has_note]
  end
end