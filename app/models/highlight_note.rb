class HighlightNote < ActiveRecord::Base
  belongs_to :noteable, :polymorphic => true
  belongs_to :note_writer, :class_name => "Login", :foreign_key => 'login_id'
end
