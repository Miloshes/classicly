FactoryGirl.define do
  factory :download_format do |f|
    f.format 'pdf'
    f.download_status 'downloaded'
  end
end