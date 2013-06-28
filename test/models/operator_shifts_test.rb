require 'test_helper'

class OperatorShiftsTest < ActiveSupport::TestCase
  test 'should get operator shifts between dates' do
    shifts =  OperatorShifts.find(:all, params: {
      user_id: 1,
      pay_pending_shifts_for_user_between: {
        start: 1.month.ago.to_date, finish: Date.today
      }
    })

    assert_equal @operator_shifts.size, shifts.size
  end

  test 'should get operator shifts for paginate' do
    shifts = OperatorShifts.get(:paginate, 
      user_id: 1, offset: 0, limit: 10
    )

    assert_equal @operator_shifts.size, shifts.size
  end
end
