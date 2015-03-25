require 'test_helper'

class MediaLibrariesControllerTest < ActionController::TestCase
  test "libraries index" do
    get :index
    assert_response :success
    assert !assigns(:media_libraries).empty?
  end

  test "libraries index empty" do
    MediaLibrary.all.each {|m| m.destroy }
    get :index
    assert_response :success
    assert assigns(:media_libraries)
  end

  test "library new" do
    get :new
    assert_response :success
    assert assigns(:media_library)
  end

  test "library show" do
    get :show, id: media_libraries(:library1).id
    assert_response :success
    assert assigns(:media_library)
  end

  test "library show empty" do
    m = media_libraries(:library1)
    m.media_files.all.each {|f| f.destroy }
    
    get :show, id: media_libraries(:library1).id
    assert_response :success
    assert assigns(:media_library)
  end

  test "library create success" do
    post :create, media_library: {name: "library2", path: Rails.root.join("test/library_fixtures/library2").to_s}
    assert_response :redirect
    assert_redirected_to media_library_path(assigns(:media_library))
  end

  test "library create error" do
    post :create, media_library: {name: "", path: Rails.root.join("test/library_fixtures/library2").to_s}
    assert_response :success
    assert_template :new
  end
    
end
