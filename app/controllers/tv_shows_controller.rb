class TvShowsController < ApplicationController
  def show
    @tv_show = TvShow.find(params[:id])
    @tv_library = @tv_show.tv_library
    @tv_seasons = @tv_show.tv_seasons.order(:name)

    if @tv_seasons.length == 1
      redirect_to tv_season_path(@tv_seasons.first)
    end
  end
end
