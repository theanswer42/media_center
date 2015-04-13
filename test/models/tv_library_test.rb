require 'test_helper'

class TvLibraryTest < ActiveSupport::TestCase
  def setup
    FileUtils.rm_rf(Rails.root.join("test/library_fixtures/tv_library1/show3"))
  end
  
  test "scan path no episodes" do
    m = TvLibrary.new(name: "Library 2", path: Rails.root.join("test/library_fixtures/library2"))
    assert m.save!
    assert_equal 2, m.media_files.where(status: MediaFile::STATUS_ENABLED).count
    
    m.media_files.all.each do |media_file|
      assert media_file.valid?
    end
    assert m.scanned_at

    assert_equal 0, m.tv_shows.count
  end

  test "scan path" do
    tv_library = TvLibrary.first
    tv_library.destroy

    tv_library = TvLibrary.new(name: "TV Library 1", path: Rails.root.join("test/library_fixtures/tv_library1"))
    tv_library.save!

    assert_equal 2, tv_library.tv_shows.count
    check_show1(tv_library)
    check_show2(tv_library)

    # Rescan
    tv_library.scan
    assert_equal 2, tv_library.tv_shows.count
    check_show1(tv_library)
    check_show2(tv_library)
    
  end

  def check_show2(tv_library)
    tv_show2 = tv_library.tv_shows.where(name: "show2").first
    assert_equal 2, tv_show2.tv_seasons.count
    season1 = tv_show2.tv_seasons.where(name: "season1").first
    assert_equal 1, season1.tv_episodes.count
    season2 = tv_show2.tv_seasons.where(name: "season2").first
    assert_equal 1, season2.tv_episodes.count
  end
  
  def check_show1(tv_library)
    tv_show1 = tv_library.tv_shows.where(name: "show1").first
    assert_equal 1, tv_show1.tv_seasons.count
    tv_season1_1 = tv_show1.tv_seasons.first
    assert_equal "default", tv_season1_1.name
    assert_equal 2, tv_season1_1.tv_episodes.count
    episode1 = tv_season1_1.tv_episodes.where(name: "video1").first
    assert episode1.media_file
    assert episode1.subtitles_file
    episode2 = tv_season1_1.tv_episodes.where(name: "video2").first
    assert episode2.media_file
    assert !episode2.subtitles_file
    
  end
  
  test "scan path add remove things" do
    tv_library = TvLibrary.first
    tv_library.destroy

    tv_library = TvLibrary.new(name: "TV Library 1", path: Rails.root.join("test/library_fixtures/tv_library1"))
    tv_library.save!
    
    # Add a show, one season
    add_video("episode1", "show3", "season1")
    add_video("episode2", "show3", "season1")

    tv_library.scan
    check_show1(tv_library)
    check_show2(tv_library)
    assert_equal 3, tv_library.tv_shows.count

    show3 = tv_library.tv_shows.where(name: "show3").first
    assert_equal 1, show3.tv_seasons.count
    season1 = show3.tv_seasons.where(name: "season1").first
    assert_equal 2, season1.tv_episodes.count
    
    # Add a season to an existing show
    add_video("episode1", "show3", "season2")
    add_video("episode2", "show3", "season2")
    add_video("episode3", "show3", "season2")
    
    tv_library.scan

    show3 = tv_library.tv_shows.where(name: "show3").first
    assert_equal 2, show3.tv_seasons.count
    season1 = show3.tv_seasons.where(name: "season1").first
    assert_equal 2, season1.tv_episodes.count

    season2 = show3.tv_seasons.where(name: "season2").first
    assert_equal 3, season2.tv_episodes.count
    
    # Add an episode to an existing season
    add_video("episode4", "show3", "season2")

    tv_library.scan

    show3 = tv_library.tv_shows.where(name: "show3").first
    season2 = show3.tv_seasons.where(name: "season2").first
    assert_equal 4, season2.tv_episodes.count
    
    # remove an episode
    remove_video("episode4", "show3", "season2")

    tv_library.scan

    show3 = tv_library.tv_shows.where(name: "show3").first
    season2 = show3.tv_seasons.where(name: "season2").first
    assert_equal 3, season2.tv_episodes.count

    # remove a season
    remove_video("episode1", "show3", "season2")
    remove_video("episode2", "show3", "season2")
    remove_video("episode3", "show3", "season2")

    tv_library.scan

    show3 = tv_library.tv_shows.where(name: "show3").first
    assert_equal 1, show3.tv_seasons.count
    assert !show3.tv_seasons.where(name: "season2").first
    
    # remove all seasons
    remove_video("episode1", "show3", "season1")
    remove_video("episode2", "show3", "season1")

    tv_library.scan
    assert_equal 2, tv_library.tv_shows.count
    check_show1(tv_library)
    check_show2(tv_library)
  end

  def remove_video(name, show, season)
    FileUtils.rm_f(Rails.root.join("test/library_fixtures/tv_library1", show, season, "#{name}.mp4"))
  end
  
  def add_video(name, show, season)
    season_path = Rails.root.join("test/library_fixtures/tv_library1", show, season)
    FileUtils.mkdir_p(season_path)
    f = File.open(File.join(season_path, "#{name}.mp4"), "w")
    f << "#{show} - #{season} - #{name}\n"
    f.close
  end
end
