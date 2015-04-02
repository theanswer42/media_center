require 'test_helper'

class TvLibrariesControllerTest < ActionController::TestCase
  test "library show" do
    get :show, id: media_libraries(:tv_library1).id
    assert_response :success
    assert assigns(:tv_library)
    assert !assigns(:tv_shows).empty?
  end

  test "library show empty" do
    m = TvLibrary.find(media_libraries(:tv_library1).id)
    
    m.tv_shows.all.each {|s| s.destroy }
        
    get :show, id: media_libraries(:tv_library1).id
    assert_response :success
    assert assigns(:tv_library)
    assert assigns(:tv_shows).empty?
  end
end
