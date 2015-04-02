class TvSeason < ActiveRecord::Base
  belongs_to :tv_show
  has_many :tv_episodes
  
end
