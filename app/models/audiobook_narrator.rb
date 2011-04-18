class AudiobookNarrator < ActiveRecord::Base
  has_many :narrated_chapters, :class_name => 'AudiobookChapter'
  
  validates_presence_of :name
end
