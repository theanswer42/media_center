class MediaFilesController < ApplicationController
  def show
    @media_library = MediaLibrary.find(params[:media_library_id])
    @media_file = @media_library.media_files.find(params[:id])
  end
end
