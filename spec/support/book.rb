FactoryGirl.define do

  factory :book do
    title "book title"
    pretty_title "book pretty title"
    is_rendered_for_online_reading false
    author
  end

  sequence :pretty_title do |n|
    "book_#{n}_pretty_title"
  end

end
