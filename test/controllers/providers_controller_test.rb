require 'test_helper'

class ProvidersControllerTest < ActionController::TestCase

  setup do
    @provider = Fabricate(:provider)
    @user = Fabricate(:user)
    sign_in @user
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:providers)
    assert_select '#unexpected_error', false
    assert_template "providers/index"
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:provider)
    assert_select '#unexpected_error', false
    assert_template "providers/new"
  end

  test "should create provider" do
    assert_difference('Provider.count') do
      post :create, params: { provider: Fabricate.attributes_for(:provider) }
    end

    assert_redirected_to provider_url(assigns(:provider))
  end

  test "should show provider" do
    get :show, params: { id: @provider }
    assert_response :success
    assert_not_nil assigns(:provider)
    assert_select '#unexpected_error', false
    assert_template "providers/show"
  end

  test "should get edit" do
    get :edit, params: { id: @provider }
    assert_response :success
    assert_not_nil assigns(:provider)
    assert_select '#unexpected_error', false
    assert_template "providers/edit"
  end

  test "should update provider" do
    put :update, params: {
      id: @provider,
      provider: Fabricate.attributes_for(:provider, name: 'value')
    }
    assert_redirected_to provider_url(assigns(:provider))
  end

  test "should destroy provider" do
    assert_difference('Provider.count', -1) do
      delete :destroy, params: { id: @provider }
    end

    assert_redirected_to providers_path
  end
end
