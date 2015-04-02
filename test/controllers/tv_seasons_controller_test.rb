require 'test_helper'

class TvSeasonsControllerTest < ActionController::TestCase
  test "show" do
    get :show, id: tv_seasons(:show2_season1).id
    assert_response :success
    assert assigns(:tv_season)
    assert !assigns(:tv_episodes).empty?
  end
end
