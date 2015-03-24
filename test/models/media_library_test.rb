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
    
    
  end
end
