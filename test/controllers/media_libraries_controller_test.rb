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

  test "library create success" do
    post :create, media_library: {type: "MovieLibrary", name: "library2", path: Rails.root.join("test/library_fixtures/library2").to_s}
    assert_response :redirect
    assert_redirected_to movie_library_path(assigns(:media_library))
  end

  test "tv library create success" do
    t = TvLibrary.first
    t.destroy
    post :create, media_library: {type: "TvLibrary", name: "tv_library1", path: Rails.root.join("test/library_fixtures/tv_library1").to_s}
    assert_response :redirect
    assert_redirected_to tv_library_path(assigns(:media_library))
  end

  
  test "library create error" do
    post :create, media_library: {type: "MovieLibrary", name: "", path: Rails.root.join("test/library_fixtures/library2").to_s}
    assert_response :success
    assert_template :new
  end
    
end
