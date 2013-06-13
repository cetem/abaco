require 'test_helper'

class OperatorsControllerTest < ActionController::TestCase
  setup do
    sign_in Fabricate(:user)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:operators)
    assert_select '#unexpected_error', false
    assert_template 'operators/index'
  end

  test "should show operator" do
    get :show, id: 1
    assert_response :success
    assert_not_nil assigns(:operator)
    assert_select '#unexpected_error', false
    assert_template 'operators/show'
  end
end
