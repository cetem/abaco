require 'test_helper'

class OperatorTest < ActiveSupport::TestCase
  test 'should get operator' do
    operator = RemoteOperator.find(@generic_operator[:abaco_id])

    assert_equal @generic_operator[:abaco_id], operator.id
    assert_equal @generic_operator[:label], operator.label
  end

  test 'should get operator autocomplete' do
    operator = RemoteOperator.get(:autocomplete_for_user_name, q: 'operator')

    assert_equal @generic_operator, operator.symbolize_keys
  end

  test 'should pay shift between dates' do
    assert RemoteOperator.find(@generic_operator[:abaco_id]).patch(
      :pay_shifts_between, start: 1.month.ago.to_date, finish: Date.today
    )
  end

  test 'show operator label' do
    Fabricate(:operator, id: @generic_operator[:abaco_id], name: @generic_operator[:label])

    movement = Fabricate(
      :movement,
      kind:            :payoff,
      to_account_type: 'Operator',
      to_account_id:   @generic_operator[:abaco_id],
      bill:            nil
    )

    assert_equal @generic_operator[:label], movement.to_account.name
  end
end
