class MediaFile < ActiveRecord::Base
  MEDIA_EXTENSIONS = %w(.mp4) +
                     %w(.mp3 .ogg .oga)
  
  belongs_to :media_library

  STATUS_ENABLED = "enabled"
  STATUS_DELETED = "deleted"
  STATUS_MISSING = "missing"

  after_initialize :set_status
  after_initialize :set_checksum

  before_validation :make_path_real
  
  validates :checksum, presence: true, uniqueness: {scope: :media_library}
  validates :path, presence: true
  validates :name, presence: true
  validates :status, presence: true, inclusion: [STATUS_ENABLED, STATUS_DELETED, STATUS_MISSING]
  validate :path_is_media_file
  

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
    return if path.blank? || !File.file?(path)
    
    self.checksum = File.open(path, 'rb') do |io|
      dig = Digest::SHA256.new
      buf = ""
      dig.update(buf) while io.read(4096, buf)
      dig
    end.to_s
  end

  private
  def set_status
    self.status = STATUS_ENABLED unless status
  end
  
  def make_path_real
    # Make it fail later if path is not absolute (implied by the media_library_path match)
    self.path = File.realpath(path) if !path.blank? && path.match(/^\//) && status != STATUS_MISSING
  end
  
  def path_is_media_file
    return if status == STATUS_MISSING
    
    if !path || !File.file?(path) || !path.match(/^#{media_library.path}/) || !MEDIA_EXTENSIONS.include?(File.extname(path))
      errors.add(:path, "must be a path to a media file in the library")
    end
  end
  
end
