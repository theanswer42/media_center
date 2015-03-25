class MediaLibrariesController < ApplicationController
  def index
    @media_libraries = MediaLibrary.all
  end

  def new
    @media_library = MediaLibrary.new
  end

  def create
    @media_library = MediaLibrary.new(params.require(:media_library).permit(:name, :path))
    if @media_library.save
      redirect_to media_library_path(@media_library)
    else
      render "new"
    end
  end
  
  def show
    @media_library = MediaLibrary.find(params[:id])
    
  end

end
