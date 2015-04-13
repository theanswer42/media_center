class TvLibrary < MediaLibrary
  has_many :tv_shows, dependent: :destroy

  def after_scan
    media_files = self.media_files.where(status: MediaFile::STATUS_ENABLED).all
    media_files_hash = {}
    media_library_path = self.path
    media_files.each do |media_file|
      full_name = media_file.path[media_library_path.length..-(File.extname(media_file.path).length+1)]
      media_files_hash[full_name] ||= {video: nil, subtitles: nil}
      media_files_hash[full_name][:subtitles] = media_file if media_file.is_subtitles_file?
      media_files_hash[full_name][:video] = media_file if media_file.is_video_file?
    end

    # Get all the current meta data
    seasons_hash = {}
    shows_hash = {}

    shows_by_name = {}
    
    episodes_hash = {}
    self.tv_shows.includes(:tv_seasons).each do |tv_show|
      shows_by_name[tv_show.name]||={object: tv_show, seasons: {}}
      tv_show.tv_seasons.each do |tv_season|
        shows_by_name[tv_show.name][:seasons][tv_season.name]=tv_season
        seasons_hash[tv_season.id] ||= {tv_show_id: tv_show.id, exists: false, object: tv_season}
        shows_hash[tv_show.id] = {exists: false, object: tv_show}
        tv_season.tv_episodes.each do |tv_episode|
          episodes_hash[tv_episode.media_file_id] = tv_episode
        end
      end
    end
    
    media_files_hash.each do |full_name, media_files|
      next if media_files[:video].blank?

      video_file = media_files[:video]
      tv_episode = episodes_hash[video_file.id] || TvEpisode.new(media_file_id: video_file.id)
      if media_files[:subtitles]
        tv_episode.subtitles_file_id = media_files[:subtitles].id
      elsif tv_episode.subtitles_file_id
        tv_episode.subtitles_file_id = nil
      end
      tv_episode.name = video_file.name if tv_episode.name.blank?

      if tv_episode.tv_season_id
        seasons_hash[tv_episode.tv_season_id][:exists] = true
        shows_hash[seasons_hash[tv_episode.tv_season_id][:tv_show_id]][:exists] = true
      else
        dirname = File.split(full_name).first
        dir_split = File.split(dirname)
        name1 = dir_split.last
        name2 = File.split(dir_split.first).last
        if(name1==name2 || name2=="/")
          show = name1
          season = "default"
        else
          season = name1
          show = name2
        end

        if shows_by_name[show]
          tv_show = shows_by_name[show][:object]
        else
          tv_show = self.tv_shows.create(name: show)
          shows_by_name[show] = {object: tv_show, seasons: {}}
        end
        if shows_by_name[show][:seasons][season]
          tv_season = shows_by_name[show][:seasons][season]
        else
          tv_season = tv_show.tv_seasons.create(name: season)
          shows_by_name[show][:seasons][season] = tv_season
        end

        tv_episode.tv_season_id = tv_season.id
      end
      
      tv_episode.save if tv_episode.changed? || tv_episode.new_record?
      
      episodes_hash.delete(video_file.id)
    end

    episodes_hash.values.each do |tv_episode|
      tv_episode.destroy
    end
    
    seasons_hash.each do |tv_season_id, info|
      info[:object].destroy if !info[:exists]
    end

    shows_hash.each do |tv_show_id, info|
      info[:object].destroy if !info[:exists]
    end
    
  end
end
