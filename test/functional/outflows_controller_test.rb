require 'test_helper'

class OutflowsControllerTest < ActionController::TestCase
  setup do
    @outflow = Fabricate(:outflow)
    sign_in Fabricate(:user)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:outflows)
    assert_select '#unexpected_error', false
    assert_template 'outflows/index'
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:outflow)
    assert_select '#unexpected_error', false
    assert_template 'outflows/new'
  end

  test "should create outflow" do
    assert_difference('Outflow.count') do
      post :create, outflow: Fabricate.attributes_for(:outflow)
    end

    assert_redirected_to outflow_url(assigns(:outflow))
  end

  test "should show outflow" do
    get :show, id: @outflow
    assert_response :success
    assert_not_nil assigns(:outflow)
    assert_select '#unexpected_error', false
    assert_template 'outflows/show'
  end

  test "should get edit" do
    get :edit, id: @outflow
    assert_response :success
    assert_not_nil assigns(:outflow)
    assert_select '#unexpected_error', false
    assert_template 'outflows/edit'
  end

  test "should update outflow" do
    put :update, id: @outflow, 
      outflow: Fabricate.attributes_for(:outflow, amount: 85)
    
    assert_redirected_to outflow_url(assigns(:outflow))
    assert_equal 85, @outflow.reload.amount
  end

  test "should destroy outflow" do
    assert_difference('Outflow.count', -1) do
      delete :destroy, id: @outflow
    end

    assert_redirected_to outflows_url
  end
end
