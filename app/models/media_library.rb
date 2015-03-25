class MediaLibrary < ActiveRecord::Base
  has_many :media_files, dependent: :destroy

  before_validation :strip_spaces
  before_validation :make_path_real

  after_create :scan
  
  validates :name, :path, presence: true, uniqueness: true
  validates :path, uniqueness: true
  validate :path_is_a_directory
  validate :path_is_absolute


  def scan
    checksums_in_library = self.media_files.all.each_with_object({}) do |media_file, hash|
      hash[media_file.checksum] = media_file.status
    end
    media_files_to_save = {}
    
    Dir.glob(File.join(path, "**", "*")).each do |filename|
      extname = File.extname(filename)
      next unless MediaFile::MEDIA_EXTENSIONS.include?(extname.downcase)
      media_file = self.media_files.build(path: filename, name: File.basename(filename, extname))

      if !checksums_in_library[media_file.checksum]
        media_files_to_save[media_file.checksum] = media_file
      else
        existing_status = checksums_in_library[media_file.checksum]
        if existing_status == MediaFile::STATUS_MISSING
          missing_media_file = self.media_files.where(checksum: media_file.checksum, status: MediaFile::STATUS_MISSING).first
          missing_media_file.path = media_file.path
          missing_media_file.status = MediaFile::STATUS_ENABLED
          media_files_to_save[media_file.checksum] = missing_media_file
        else
          checksums_in_library[media_file.checksum] = "accounted"
        end
      end
    end
    
    media_files_to_save.values.each do |media_file|
      if media_file.save
        checksums_in_library[media_file.checksum] = "accounted"
      else
        logger.error("File not imported: #{filename}")
      end
    end

    checksums_in_library.each do |checksum, status|
      if status != "accounted"
        media_file = self.media_files.where(checksum: checksum).first
        media_file.mark_missing
      end
    end
    self.scanned_at = Time.now
    save
  end


  
  private
  def make_path_real
    self.path = File.realpath(path) if !path.blank? && path.match(/^\//) && File.directory?(path)
  end

  def strip_spaces
    self.name = self.name.strip if self.name
    self.path = self.path.strip if self.path
  end

  def path_is_absolute
    if !path || !path.match(/^\//)
      errors.add(:path, "must be an absolute path")
    end
  end
  
  def path_is_a_directory
    if !path || !File.directory?(path)
      errors.add(:path, "must be a directory")
    end
  end
  
end
