class TvShowsController < ApplicationController
  def show
    @tv_show = TvShow.find(params[:id])
    @tv_seasons = @tv_show.tv_seasons
  end
end
