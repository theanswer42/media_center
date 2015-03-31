class Movie < ActiveRecord::Base
  belongs_to :movie_library
  belongs_to :media_file
  belongs_to :subtitles_file, class_name: MediaFile
  
end
