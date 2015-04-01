require 'test_helper'

class MovieLibrariesControllerTest < ActionController::TestCase
  test "library show" do
    get :show, id: media_libraries(:library1).id
    assert_response :success
    assert assigns(:movie_library)
  end

  test "library show empty" do
    m = MovieLibrary.find(media_libraries(:library1).id)
    
    m.media_files.all.each {|f| f.destroy }
    m.movies.all.each {|m| m.destroy }
    
    
    get :show, id: media_libraries(:library1).id
    assert_response :success
    assert assigns(:movie_library)
  end
end
