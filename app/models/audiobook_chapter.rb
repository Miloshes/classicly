class AudiobookChapter < ActiveRecord::Base
  belongs_to :audiobook
  belongs_to :narrator, :class_name => 'AudiobookNarrator', :foreign_key => 'audiobook_narrator_id'
end
