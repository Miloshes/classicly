# CLEANUP: remove, obsolete model
class Genre < ActiveRecord::Base
  has_and_belongs_to_many :books
  has_one :collection
  validates :name, :presence => true
end
