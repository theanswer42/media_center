require 'test_helper'

class MediaLibraryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
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
    m = MediaLibrary.new(:name => "Library 2", :path => Rails.root.join("test/library_fixtures/../library_fixtures/library2"))
    assert m.save
    assert_equal 2, m.media_files.count
  end

  
end
