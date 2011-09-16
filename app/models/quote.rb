class Quote < ActiveRecord::Base
  # associations
  belongs_to  :collection
  has_many  :seo_slugs, :as => :seoable
  #extensions
  has_friendly_id :content, :use_slug => true
end
