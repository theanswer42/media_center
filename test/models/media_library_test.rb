require 'test_helper'

class MediaLibraryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    FileUtils.rm_f(Rails.root.join("test/library_fixtures/library1/new_video5.mp4"))
    FileUtils.rm_f(Rails.root.join("test/library_fixtures/library1/new_video6.mp4"))
  end
  
  test "validations" do
    m = MediaLibrary.new(:name => "Library 2", :path => "")
    assert !m.valid?

    m = MediaLibrary.new(:name => "Library 2", :path => "/path/does/not/exist")
    assert !m.valid?

    m = MediaLibrary.new(:name => "Library 2", :path => Rails.root.join("test/library_fixtures/library2"))
    assert m.valid?

    m = MediaLibrary.new(:name => "", :path => Rails.root.join("test/library_fixtures/library2"))
    assert !m.valid?

    m = MediaLibrary.new(:name => "Library 1", :path => Rails.root.join("test/library_fixtures/library2"))
    assert !m.valid?

    m = MediaLibrary.new(:name => "  Library 1   ", :path => Rails.root.join("test/library_fixtures/library2"))
    assert !m.valid?
    
    m = MediaLibrary.new(:name => "Library 2", :path => Rails.root.join("test/library_fixtures/library1"))
    assert !m.valid?

    m = MediaLibrary.new(:name => "Library 2", :path => "   " + Rails.root.join("test/library_fixtures/library1").to_s)
    assert !m.valid?
  end

  test "strip spaces before saving" do
    m = MediaLibrary.new(:name => "   Library 2    ", :path => Rails.root.join("test/library_fixtures/library2").to_s + "    ")
    assert m.save

    assert_equal "Library 2", m.name
    assert_equal Rails.root.join("test/library_fixtures/library2").to_s, m.path
  end

  test "make path real" do
    m = MediaLibrary.new(:name => "Library 2", :path => Rails.root.join("test/library_fixtures/../library_fixtures/library2"))
    assert m.save

    assert_equal Rails.root.join("test/library_fixtures/library2").to_s, m.path
  end

  test "scan path" do
    m = MediaLibrary.new(name: "Library 2", path: Rails.root.join("test/library_fixtures/library2"))
    assert m.save!
    assert_equal 2, m.media_files.where(status: MediaFile::STATUS_ENABLED).count
    
    m.media_files.all.each do |media_file|
      assert media_file.valid?
    end
    assert m.scanned_at
  end

  test "rescan no change" do
    m = MediaLibrary.new(name: "Library 2", path: Rails.root.join("test/library_fixtures/library2"))
    assert m.save!
    assert_equal 2, m.media_files.count
    m.media_files.all.each do |media_file|
      assert media_file.valid?
      assert_equal MediaFile::STATUS_ENABLED, media_file.status
    end
    assert m.scanned_at
    scanned_at = m.scanned_at
    sleep 1

    m.scan
    assert_equal 2, m.media_files.count
    assert_equal 2, m.media_files.count
    m.media_files.all.each do |media_file|
      assert media_file.valid?
    end
    assert m.scanned_at > scanned_at
  end

  test "rescan new file" do
    m = media_libraries(:library1)
    assert_equal 2, m.media_files.count
    assert !m.media_files.all.detect {|f| f.name == "new_video4" }
    
    m.scan
    assert_equal 3, m.media_files.where(status: MediaFile::STATUS_ENABLED).count
    assert m.media_files.all.detect {|f| f.name == "new_video4" }
  end
  
  test "rescan missing" do
    missing_file = media_files(:video1)
    missing_file.mark_missing

    m = media_libraries(:library1)
    m = MediaLibrary.find(m.id)

    assert_equal 2, m.media_files.count
    assert_equal 1, m.media_files.where(status: MediaFile::STATUS_ENABLED).count
    
    f = File.open(Rails.root.join("test/library_fixtures/library1/new_video5.mp4"), "wb")
    f << "new video 5\n"
    f.close

    m.scan
    assert_equal 4, m.media_files.where(status: MediaFile::STATUS_ENABLED).count
    
    not_missing = MediaFile.find(missing_file.id)
    assert_equal MediaFile::STATUS_ENABLED, not_missing.status

    will_be_missing = m.media_files.where(:name => "new_video5").first
    FileUtils.rm(Rails.root.join("test/library_fixtures/library1/new_video5.mp4"))

    m.scan

    assert_equal 4, m.media_files.count
    assert_equal 3, m.media_files.where(status: MediaFile::STATUS_ENABLED).count

    now_missing = MediaFile.find(will_be_missing.id)
    assert_equal MediaFile::STATUS_MISSING, now_missing.status
  end

  test "rescan moved" do
    m = media_libraries(:library1)

    assert_equal 2, m.media_files.count
    assert_equal 2, m.media_files.where(status: MediaFile::STATUS_ENABLED).count
    
    f = File.open(Rails.root.join("test/library_fixtures/library1/new_video5.mp4"), "wb")
    f << "new video 5\n"
    f.close

    m.scan
    assert_equal 4, m.media_files.where(status: MediaFile::STATUS_ENABLED).count
    
    FileUtils.mv(Rails.root.join("test/library_fixtures/library1/new_video5.mp4"),
                 Rails.root.join("test/library_fixtures/library1/new_video6.mp4"))
    
    m.scan

    assert_equal 4, m.media_files.count
    assert_equal 4, m.media_files.where(status: MediaFile::STATUS_ENABLED).count

    moved_file = m.media_files.where(:name => "new_video5").first
    assert_equal Rails.root.join("test/library_fixtures/library1/new_video6.mp4").to_s, moved_file.path
    
    FileUtils.rm(Rails.root.join("test/library_fixtures/library1/new_video6.mp4"))

    m.scan

    assert_equal 4, m.media_files.count
    assert_equal 3, m.media_files.where(status: MediaFile::STATUS_ENABLED).count    
  end

end
