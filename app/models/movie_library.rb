class MovieLibrary < MediaLibrary
  has_many :movies, dependent: :destroy
  
  def after_scan
    ####
    # TODO
    ####
    # Here, I assume that a movie does not have multiple video files.
    # For example, a movie could have an mp4, ogg and vp9
    # If and when I start having multiple video files per movie, I will have to fix this
    ####
        
    movies_hash = self.movies.all.each_with_object({}) {|movie, hash| hash[movie.media_file_id] = movie }

    media_files = self.media_files.where(status: MediaFile::STATUS_ENABLED).all
    media_files_hash = {}
    media_library_path = self.path
    media_files.each do |media_file|
      full_name = media_file.path[media_library_path.length..-(File.extname(media_file.path).length+1)]
      media_files_hash[full_name] ||= {video: nil, subtitles: nil}
      media_files_hash[full_name][:subtitles] = media_file if media_file.is_subtitles_file?
      media_files_hash[full_name][:video] = media_file if media_file.is_video_file?
    end

    media_files_hash.each do |full_name, media_files|
      next if media_files[:video].blank?

      video_file = media_files[:video]
      movie = movies_hash[video_file.id]||self.movies.build(media_file_id: video_file.id)
      if media_files[:subtitles]
        movie.subtitles_file_id = media_files[:subtitles].id
      elsif movie.subtitles_file_id
        movie.subtitles_file_id = nil
      end
      movie.name = video_file.name if movie.name.blank?

      movie.save if movie.changed? || movie.new_record?
      
      movies_hash.delete(video_file.id)
    end

    movies_hash.values.each do |movie|
      movie.destroy
    end
    
  end
end
