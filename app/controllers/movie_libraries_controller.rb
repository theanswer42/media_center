class MovieLibrariesController < ApplicationController
  def show
    @movie_library = MovieLibrary.find(params[:id])
    @movies = @movie_library.movies
  end
end
