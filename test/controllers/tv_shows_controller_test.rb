require 'test_helper'

class TvShowsControllerTest < ActionController::TestCase
  test "test show single season" do
    
  end

  test "test show multiple seasons" do
    get :show, id: tv_shows(:show2).id
    assert_response :success
    assert assigns(:tv_show)
    assert_equal 2, assigns(:tv_seasons).length
  end
end
