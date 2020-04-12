require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  setup do
    @setting = Fabricate(:setting)
    sign_in Fabricate(:user)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:settings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create setting" do
    assert_difference('Setting.count') do
      post :create, params: { setting: Fabricate.attributes_for(:setting) }
    end

    assert_redirected_to setting_path(assigns(:setting))
  end

  test "should show setting" do
    get :show, params: { id: @setting }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { id: @setting }
    assert_response :success
  end

  test "should update setting" do
    put :update, params: { id: @setting, setting: Fabricate.attributes_for(:setting) }
    assert_redirected_to setting_path(assigns(:setting))
  end
end
