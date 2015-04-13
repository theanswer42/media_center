class TvSeasonsController < ApplicationController
  def show
    @tv_season = TvSeason.find(params[:id])
    @tv_show = @tv_season.tv_show
    @tv_library = @tv_show.tv_library
    @tv_episodes = @tv_season.tv_episodes.order(:name)
  end
end
