class MediaLibrary < ActiveRecord::Base
  has_many :media_files, dependent: :destroy

  before_validation :strip_spaces

  after_save :scan_path
  
  validates :name, :path, presence: true, uniqueness: true
  validates :path, uniqueness: true
  validate :path_is_a_directory
  validate :path_is_absolute

  private
  def strip_spaces
    name = name.strip if name
    path = path.strip if path
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
    Dir.glob(path, "**", "*") do |filename|
      next unless MediaFile::MEDIA_EXTENSIONS.include?(File.extname(filename).downcase)
      
      
    end
  end
end
