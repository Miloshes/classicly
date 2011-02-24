class CollectionAudiobookAssignment < ActiveRecord::Base
  belongs_to :audiobook
  belongs_to :collection
end
