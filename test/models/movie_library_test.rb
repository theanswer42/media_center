require 'test_helper'

class MovieLibraryTest < ActiveSupport::TestCase
  def setup
    FileUtils.rm_f(Rails.root.join("test/library_fixtures/library3/video23.mp4"))
    FileUtils.rm_f(Rails.root.join("test/library_fixtures/library3/video24.mp4"))
    FileUtils.rm_f(Rails.root.join("test/library_fixtures/library3/video22.vtt"))
  end

  test "scan path no movies" do
    m = MovieLibrary.new(name: "Library 2", path: Rails.root.join("test/library_fixtures/library2"))
    assert m.save!
    assert_equal 2, m.media_files.where(status: MediaFile::STATUS_ENABLED).count
    
    m.media_files.all.each do |media_file|
      assert media_file.valid?
    end
    assert m.scanned_at

    assert_equal 0, m.movies.count
  end

  test "scan path" do
    m = MovieLibrary.new(name: "Library 3", path: Rails.root.join("test/library_fixtures/library3"))
    assert m.save!
    assert_equal 4, m.media_files.where(status: MediaFile::STATUS_ENABLED).count
    
    m.media_files.all.each do |media_file|
      assert media_file.valid?
    end
    assert m.scanned_at

    assert_equal 2, m.movies.count
    movie1 = m.movies.where(name: "video21").first
    assert movie1
    video = movie1.media_file
    subtitles = movie1.subtitles_file
    assert video
    assert subtitles

    assert_equal video.name, movie1.name

    movie2 = m.movies.where(name: "video22").first
    assert !movie2.subtitles_file_id

    movie1_updated_at = movie1.updated_at
    movie2_updated_at = movie2.updated_at
    sleep 1
    m.scan
    assert_equal 2, m.movies.count
    movie1 = m.movies.where(name: "video21").first
    assert_equal movie1_updated_at, movie1.updated_at
  end

  test "rescan adds and removes things" do
    m = MovieLibrary.new(name: "Library 3", path: Rails.root.join("test/library_fixtures/library3"))
    assert m.save!
    assert_equal 4, m.media_files.where(status: MediaFile::STATUS_ENABLED).count
    assert_equal 2, m.movies.count
    
    # Going to add:
    # 1. missing subs for a video
    f = File.open(Rails.root.join("test/library_fixtures/library3/video22.vtt"), "w")
    f << "subs 22"
    f.close
    f = File.open(Rails.root.join("test/library_fixtures/library3/video23.mp4"), "w")
    f << "video 23"
    f.close
    f = File.open(Rails.root.join("test/library_fixtures/library3/video24.mp4"), "w")
    f << "video 24"
    f.close
    
    m.scan
    assert_equal 4, m.movies.count
    movie1 = m.movies.where(:name => "video21").first
    movie2 = m.movies.where(:name => "video22").first
    movie3 = m.movies.where(:name => "video23").first
    [movie1, movie2, movie3].each do |movie|
      assert movie.media_file
      assert movie.subtitles_file
      assert_equal movie.name, movie.media_file.name
    end
    movie4 = m.movies.where(:name => "video24").first
    assert movie4.media_file
    assert !movie4.subtitles_file
    
    FileUtils.rm_f(Rails.root.join("test/library_fixtures/library3/video24.mp4"))
    FileUtils.rm_f(Rails.root.join("test/library_fixtures/library3/video22.vtt"))

    m.scan
    assert_equal 3, m.movies.count

    movie4 = m.movies.where(:name => "video24").first
    assert !movie4

    movie2 = m.movies.where(:name => "video22").first
    assert !movie2.subtitles_file
  end
  
end
