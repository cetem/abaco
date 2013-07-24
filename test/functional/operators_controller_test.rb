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
    [:upfront, :to_favor, :refunded, :payoff].each do |kind|
      Fabricate(:outflow, kind: Outflow::KIND[kind], operator_id: 1)
    end

    get :show, id: 1
    assert_response :success
    assert_not_nil assigns(:operator)
    assert_not_nil assigns(:shifts)
    assert_equal 3, assigns(:shifts).size
    assert_not_nil assigns(:movements)
    assert_equal 4, assigns(:movements).size
    assert_select '#unexpected_error', false
    assert_template 'operators/show'
  end
end
