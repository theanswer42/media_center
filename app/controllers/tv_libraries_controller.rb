class TvLibrariesController < ApplicationController
  def show
    @tv_library = TvLibrary.find(params[:id])
    @tv_shows = @tv_library.tv_shows
    
  end
end
