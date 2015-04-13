class MovieLibrariesController < ApplicationController
  def show
    @movie_library = MovieLibrary.find(params[:id])
    @movies = @movie_library.movies.order(:name)
  end
end
