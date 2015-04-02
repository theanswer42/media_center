class TvSeasonsController < ApplicationController
  def show
    @tv_season = TvSeason.find(params[:id])
    @tv_episodes = @tv_season.tv_episodes
  end
end
