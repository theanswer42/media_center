class MoviesController < ApplicationController
  def show
    @movie_library = MovieLibrary.find(params[:movie_library_id])
    @movie = @movie_library.movies.find(params[:id])
  end
end
