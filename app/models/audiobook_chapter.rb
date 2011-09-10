include AWS::S3

class AudiobookChapter < ActiveRecord::Base
  belongs_to :audiobook
  belongs_to :narrator, :class_name => 'AudiobookNarrator', :foreign_key => 'audiobook_narrator_id'

  # Returns the actual mp3 file's data
  def data_file
    AWS::S3::Base.establish_connection!(
      :access_key_id     => APP_CONFIG['amazon']['access_key'],
      :secret_access_key => APP_CONFIG['amazon']['secret_key']
    )

    return S3Object.value("#{self.id}.mp3",  APP_CONFIG['buckets']['audiobook_chapters'])
  end

end
