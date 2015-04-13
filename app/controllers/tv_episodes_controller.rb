class TvEpisodesController < ApplicationController
  def show
    @tv_episode = TvEpisode.find(params[:id])
    @tv_season = @tv_episode.tv_season
    @tv_show = @tv_season.tv_show
  end
end
