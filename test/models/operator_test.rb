require 'test_helper'

class OperatorTest < ActiveSupport::TestCase
  setup do
    skip 'Mock'
  end

  test 'should get operator' do
    operator = RemoteOperator.find(1)

    assert_equal @generic_operator[:id], operator.id
    assert_equal @generic_operator[:label], operator.label
  end

  test 'should get operator autocomplete' do
    operator = RemoteOperator.get(:autocomplete_for_user_name, q: 'operator')

    assert_equal @generic_operator, operator.symbolize_keys
  end

  test 'should pay shift between dates' do
    assert RemoteOperator.find(1).patch(
      :pay_shifts_between, start: 1.month.ago.to_date, finish: Date.today
    )
  end

  test 'show operator label' do
    movement = Fabricate(:movement, operator_id: @generic_operator[:id])

    assert_equal @generic_operator[:label], movement.operator_name
  end
end
