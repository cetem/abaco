require 'test_helper'

class OperatorShiftTest < ActiveSupport::TestCase

  test 'should get operator shifts between dates' do
    shifts =  OperatorShift.find(:all, params: {
      user_id: @generic_operator[:abaco_id],
      pay_pending_shifts_for_user_between: {
        start: 1.month.ago.to_date, finish: Date.today
      }
    })

    assert_equal @operator_shifts.size, shifts.size
  end

  test 'should get operator shifts for paginate' do
    shifts = OperatorShift.get(:json_paginate,
      user_id: @generic_operator[:abaco_id], offset: 0, limit: 10
    )

    assert_equal @operator_shifts.size, shifts.size
  end
end
