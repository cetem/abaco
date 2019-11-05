require 'test_helper'

class MovementsControllerTest < ActionController::TestCase
  setup do
    @movement = Fabricate(:movement)
    sign_in Fabricate(:user)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:movements)
    assert_select '#unexpected_error', false
    assert_template 'movements/index'
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:movement)
    assert_select '#unexpected_error', false
    assert_template 'movements/new'
  end

  test "should create movement" do
    assert_difference('Movement.count') do
      post :create, movement: Fabricate.attributes_for(:movement)
    end

    assert_redirected_to movement_url(assigns(:movement))
  end

  test "should show movement" do
    get :show, id: @movement
    assert_response :success
    assert_not_nil assigns(:movement)
    assert_select '#unexpected_error', false
    assert_template 'movements/show'
  end

  test "should get edit" do
    get :edit, id: @movement
    assert_response :success
    assert_not_nil assigns(:movement)
    assert_select '#unexpected_error', false
    assert_template 'movements/edit'
  end

  test "should update movement" do
    put :update, id: @movement,
      movement: Fabricate.attributes_for(:movement, amount: 85)

    assert_redirected_to movement_url(assigns(:movement))
    assert_equal 85, @movement.reload.amount
  end

  test "should revoke movement" do
    assert_no_difference('Movement.count') do
      delete :revoke, id: @movement
    end

    assert_redirected_to movements_url
  end
end
