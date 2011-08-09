Factory.define :book do |f|
  f.title 'book title'
  f.pretty_title
  f.is_rendered_for_online_reading false
  f.author
end

FactoryGirl.define do

  sequence :pretty_title do |n|
    "book_#{n}_pretty_title"
  end

end
