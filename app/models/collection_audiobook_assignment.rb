class CollectionAudiobookAssignment < ActiveRecord::Base
  belongs_to :audiobook
  belongs_to :collection
  
  validates :audiobook, :presence => true
  validates :collection, :presence => true
end
