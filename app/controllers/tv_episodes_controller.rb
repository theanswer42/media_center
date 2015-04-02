class TvEpisodesController < ApplicationController
  def show
    @tv_episode = TvEpisode.find(params[:id])
  end
end
