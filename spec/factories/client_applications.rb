# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :client_application do
    application_id "My ID String"
    platform "My Platform String"
  end
end
