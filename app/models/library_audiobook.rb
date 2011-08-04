class LibraryAudiobook < ActiveRecord::Base
  belongs_to :audiobook
  belongs_to :library  
end
