class MediaLibrariesController < ApplicationController
  def index
    @media_libraries = MediaLibrary.all
  end

  def new
    @media_library = MediaLibrary.new
  end

  def create
    if params[:media_library][:type]=="MovieLibrary"
      @media_library = MovieLibrary.new(params.require(:media_library).permit(:name, :path))
    else
      raise "Unsupported type"
    end
    if @media_library.save
      if @media_library.is_a?(MovieLibrary)
        redirect_to movie_library_path(@media_library)
      else
        raise "Unsupported type"
      end
    else
      render "new"
      return
    end
  end
end
