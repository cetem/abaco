require 'test_helper'

class OperatorsControllerTest < ActionController::TestCase
  setup do
    sign_in @user = Fabricate(:user)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:operators)
    assert_select '#unexpected_error', false
    assert_template 'operators/index'
  end

  test "should show operator" do

    attrs =  {
      to_account_type: 'Operator',
      to_account_id:   Fabricate(:operator).id,
      bill: nil
    }
    [:upfront, :to_favor, :refunded, :payoff].each do |kind|
      Fabricate(:movement, attrs.merge(kind: kind))
    end

    get :show, params: { id: attrs[:to_account_id] }
    assert_response :success
    assert_not_nil assigns(:operator)
    assert_not_nil assigns(:shifts)
    assert_equal 3, assigns(:shifts).size
    assert_not_nil assigns(:movements)
    assert_equal 4, assigns(:movements).size
    assert_select '#unexpected_error', false
    assert_template 'operators/show'
  end

  test "should get new shift" do
    get :new_shift, params: { id: 1 }
    assert_response :success
    assert_not_nil assigns(:operator)
    assert_not_nil assigns(:operator_shift)
    assert_select '#unexpected_error', false
    assert_template 'operators/new_shift'
  end

  test 'show create an operator shift' do
    post :create_shift, params: {
      id: @generic_operator[:id],
      operator_shift: {
        start: 5.hours.ago, finish: 2.hours.ago
      }
    }

    assert_redirected_to operator_url(@generic_operator[:abaco_id])
  end
end
