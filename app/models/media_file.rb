class MediaFile < ActiveRecord::Base
  AUDIO_EXTENSIONS = %w(.mp3 .ogg .oga)
  VIDEO_EXTENSIONS = %w(.mp4)
  SUBTITLES_EXTENSIONS = %w(.vtt)
  
  MEDIA_EXTENSIONS = AUDIO_EXTENSIONS + VIDEO_EXTENSIONS + SUBTITLES_EXTENSIONS
                     
  
  belongs_to :media_library

  STATUS_ENABLED = "enabled"
  STATUS_DELETED = "deleted"
  STATUS_MISSING = "missing"

  after_initialize :set_status
  after_initialize :set_checksum
  after_initialize :make_path_real

  before_validation :make_path_real
  
  validates :checksum, presence: true, uniqueness: {scope: :media_library}
  validates :path, presence: true
  validates :name, presence: true
  validates :status, presence: true, inclusion: [STATUS_ENABLED, STATUS_DELETED, STATUS_MISSING]
  validate :path_is_media_file

  def is_audio_file?
    AUDIO_EXTENSIONS.include?(File.extname(path))
  end

  def is_video_file?
    VIDEO_EXTENSIONS.include?(File.extname(path))
  end

  def is_subtitles_file?
    SUBTITLES_EXTENSIONS.include?(File.extname(path))
  end
  
  def library_path
    # take the relative path, prefix with the library basename
    media_library_path = self.media_library.path
    relative_path = self.path[media_library_path.length..-1]
    "/media_center/#{File.basename(media_library_path)}#{relative_path}"
  end
  
  def mark_missing
    self.status = STATUS_MISSING
    self.save
  end

  def mark_deleted
    self.status = STATUS_DELETED
    self.save
  end

  # TODO: This should move to an extension which I can use everywhere
  def set_checksum
    return if !checksum.blank?
    return if path.blank? || !File.file?(path)
    
    self.checksum = File.open(path, 'rb') do |io|
      digest = Digest::MD5.new
      buffer = ""
      digest.update(buffer) while io.read(4096, buffer)
      digest
    end.to_s
  end

  private
  def set_status
    self.status = STATUS_ENABLED unless status
  end
  
  def make_path_real
    if new_record? || path_changed?
      # Make it fail later if path is not absolute (implied by the media_library_path match)
      self.path = File.realpath(path) if !path.blank? && path.match(/^\//) && status != STATUS_MISSING
    end
  end
  
  def path_is_media_file
    return if status == STATUS_MISSING
    
    if !path || !File.file?(path) || !path.match(/^#{media_library.path}/) || !MEDIA_EXTENSIONS.include?(File.extname(path))
      errors.add(:path, "must be a path to a media file in the library")
    end
  end
  
end
