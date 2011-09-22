Factory.define :admin_user do |f|
  f.sequence(:name) {|n| "person#{n}_admin" }
  f.email
  f.password 'mypassword'
  f.password_confirmation 'mypassword'
end

FactoryGirl.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end
end
