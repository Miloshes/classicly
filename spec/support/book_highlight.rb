FactoryGirl.define do
  factory :book_highlight do
    created_at Time.now
    book
    user
    fb_connect_id { user.fb_connect_id }

    first_character 0
    last_character 29
    content "The rabbit went down the hole."

    trait :has_note do
      origin_comment "Here's my note."
    end

    factory :book_highlight_with_note, :traits => [:has_note]
  end
end