require 'test_helper'

class OperatorTest < ActiveSupport::TestCase
  test 'should get operator' do
    operator = Operator.find(1)

    assert_equal @generic_operator[:id], operator.id
    assert_equal @generic_operator[:label], operator.label
  end

  test 'should get operator autocomplete' do
    operator = Operator.get(:autocomplete_for_user_name, q: 'operator')
    
    assert_equal @generic_operator, operator.symbolize_keys
  end

  test 'should pay shift between dates' do
    assert Operator.find(1).put(
      :pay_shifts_between, start: 1.month.ago.to_date, finish: Date.today
    )
  end
end
