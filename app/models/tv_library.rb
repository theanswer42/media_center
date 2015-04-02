class TvLibrary < MediaLibrary
  has_many :tv_shows, dependent: :destroy
  
  def after_scan

  end
end
