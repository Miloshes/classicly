class SeoInfo < ActiveRecord::Base
  belongs_to :infoable, :polymorphic => true
  validates_length_of :meta_description, :within => 10..255, :on => :save, :message => "must have between 10 to 255 characters"
end