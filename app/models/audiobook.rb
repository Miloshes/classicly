class Audiobook < ActiveRecord::Base
  belongs_to :author
  belongs_to :custom_cover

  has_many :collection_audiobook_assignments
  has_many :collections, :through => :collection_audiobook_assignments

  validates :title, :presence => true

  scope :blessed, where({:blessed => true})
  scope :random, lambda { |limit| {:order => 'RANDOM()', :limit => limit }}
end
