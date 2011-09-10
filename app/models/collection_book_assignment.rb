class CollectionBookAssignment < ActiveRecord::Base
  belongs_to :book
  belongs_to :collection
  
  validates :book, :presence => true
  validates :collection, :presence => true
end
