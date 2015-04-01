require 'test_helper'

class MoviesControllerTest < ActionController::TestCase
  test "show" do
    get :show, id: movies(:movie1).id, movie_library_id: media_libraries(:library1).id
    assert_response :success
  end

end
