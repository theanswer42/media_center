class TvShow < ActiveRecord::Base
  belongs_to :tv_library
  has_many :tv_seasons, dependent: :destroy 
end
