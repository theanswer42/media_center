require 'test_helper'

class MediaFileTest < ActiveSupport::TestCase

  test "checksum computed" do
    m = media_libraries(:library1)
    
    f = m.media_files.build(:path => Rails.root.join("test/library_fixtures/library1/new_video4.mp4"))
    assert f.save
    assert_equal "02db32814a8ca1051b997c76055ececc97eed5c5cf0761ef748d374327174570", f.checksum
  end

  test "make_path_real" do
    m = media_libraries(:library1)
    
    f = m.media_files.build(:path => Rails.root.join("test/library_fixtures/../library_fixtures/library1/new_video4.mp4"))
    assert f.save
    assert_equal Rails.root.join("test/library_fixtures/library1/new_video4.mp4").to_s, f.path
  end
  
  test "validations" do
    m = media_libraries(:library1)
    
    f = m.media_files.build()
    assert !f.valid?

    f = m.media_files.build(:path => "test/library_fixtures/library1/new_video4.mp4")
    assert !f.valid?

    f = m.media_files.build(:path => Rails.root.join("test/library_fixtures/library1/new_video4.mp4"))
    assert f.valid?

    f = m.media_files.build(:path => Rails.root.join("test/library_fixtures/library2/test_audio1.mp3"))
    assert !f.valid?

    
    dup_path = Rails.root.join("test/library_fixtures/library1/dup_video1.mp4")
    assert File.file?(dup_path)
    f = m.media_files.build(:path => dup_path)
    assert !f.valid?
    
  end

end
