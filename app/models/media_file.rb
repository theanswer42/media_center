class MediaFile < ActiveRecord::Base
  MEDIA_EXTENSIONS = %w(.mp4) +
                     %w(.mp3 .ogg .oga)
  
  belongs_to :media_library

  before_validation :compute_checksum
  before_validation :make_path_real
  
  validates :checksum, presence: true, uniqueness: true
  validates :path, presence: true
  validate :path_is_media_file

  private

  # TODO: This should move to an extension which I can use everywhere
  def compute_checksum
    return if path.blank? || !File.file?(path)
    
    self.checksum = File.open(path, 'rb') do |io|
      dig = Digest::SHA256.new
      buf = ""
      dig.update(buf) while io.read(4096, buf)
      dig
    end.to_s
  end

  def make_path_real
    # Make it fail later if path is not absolute (implied by the media_library_path match)
    self.path = File.realpath(path) if !path.blank? && path.match(/^\//)
  end
  
  def path_is_media_file
    if !path || !File.file?(path) || !path.match(/^#{media_library.path}/)|| !MEDIA_EXTENSIONS.include?(File.extname(path))
      errors.add(:path, "must be a path to a media file in the library")
    end
  end
  
end
