class MediaLibrary < ActiveRecord::Base
  has_many :media_files, dependent: :destroy

  before_validation :strip_spaces
  before_validation :make_path_real

  after_save :scan_path
  
  validates :name, :path, presence: true, uniqueness: true
  validates :path, uniqueness: true
  validate :path_is_a_directory
  validate :path_is_absolute

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
  
  def scan_path
    Dir.glob(File.join(path, "**", "*")).each do |filename|
      next unless MediaFile::MEDIA_EXTENSIONS.include?(File.extname(filename).downcase)
      media_file = self.media_files.build(:path => filename)
      unless media_file.save
        logger.error("File not imported: #{filename}")
      end
    end
  end
end
