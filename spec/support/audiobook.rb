FactoryGirl.define do
  factory :audiobook do |f|
    f.title 'audiobook title'
    f.pretty_title 'audiobook pretty title'
    f.author
  end
end