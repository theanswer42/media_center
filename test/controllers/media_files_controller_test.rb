require 'test_helper'

class MediaFilesControllerTest < ActionController::TestCase
  test "show" do
    get :show, id: media_files(:video1).id, media_library_id: media_libraries(:library1).id
    assert_response :success
  end
end
