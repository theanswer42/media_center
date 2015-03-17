class MediaFile < ActiveRecord::Base
  MEDIA_EXTENSIONS = %w(mp4) +
                     %w(mp3 ogg oga)
  
  belongs_to :media_library

  
end
