class Audiobook < ActiveRecord::Base
  belongs_to :author
  belongs_to :custom_cover

  has_many :collection_audiobook_assignments
  has_many :collecions, :through => :collection_audiobook_assignments
  
  validates :title, :presence => true
  
end
