class Rating < ActiveRecord::Base
  belongs_to :rateable, :polymorphic => true
  belongs_to :rater, :class_name => "Login", :foreign_key => 'login_id'
  validates_presence_of :score

end
