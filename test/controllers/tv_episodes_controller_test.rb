require 'test_helper'

class TvEpisodesControllerTest < ActionController::TestCase
  test "show" do
    get :show, id: tv_episodes(:show2_season1_video21).id
    assert_response :success
    assert assigns(:tv_episode)
  end
end
