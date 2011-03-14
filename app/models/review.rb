class Review < ActiveRecord::Base
  belongs_to :reviewer, :class_name => "User", :foreign_key => "user_id"
  belongs_to :reviewable, :polymorphic => true
end
