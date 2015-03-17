class MediaLibrariesController < ApplicationController
  def index
    @media_libraries = MediaLibrary.all
    @media_library = MediaLibrary.new
  end

  def create
    @media_library = MediaLibrary.new(params.require(:media_library).permit(:name, :path))
    if @media_library.save
      redirect_to media_libraries_path
    else
      render "new"
    end
  end
end
