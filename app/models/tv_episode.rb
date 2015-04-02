class TvEpisode < ActiveRecord::Base
  belongs_to :tv_season
  belongs_to :media_file
  belongs_to :subtitles_file, class_name: MediaFile

end
