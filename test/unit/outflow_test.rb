require 'test_helper'

class OutflowTest < ActiveSupport::TestCase
  setup do
    @outflow = Fabricate(:outflow)

    ['pay_per_administrator_hour', 'pay_per_operator_hour'].each do |setting|
      Setting.create!(title: setting, var: setting, value: rand(100))
    end
  end
  
  test 'create' do
    assert_difference ['Outflow.count', 'Version.count'] do
      @outflow = Outflow.create(Fabricate.attributes_for(:outflow))
    end
  end
  
  test 'update' do
    assert_difference 'Version.count' do
      assert_no_difference 'Outflow.count' do
        assert @outflow.update_attributes(comment: 'Updated')
      end
    end
    
    assert_equal 'Updated', @outflow.reload.comment
  end
  
  test 'destroy' do
    assert_difference 'Version.count' do
      assert_difference('Outflow.count', -1) { @outflow.destroy }
    end
  end
  
  test 'validates blank attributes' do
    @outflow.kind = 'u'
    @outflow.operator_id = ''
    
    assert @outflow.invalid?
    assert_equal 1, @outflow.errors.size
    assert_equal [error_message_from_model(@outflow, :operator_id, :blank)],
      @outflow.errors[:operator_id]
    
    @outflow.kind = 'o'
    @outflow.comment = ''
    
    assert @outflow.invalid?
    assert_equal 1, @outflow.errors.size
    assert_equal [error_message_from_model(@outflow, :comment, :blank)],
      @outflow.errors[:comment]
    
    @outflow.amount = ''
    @outflow.kind = ''
    @outflow.user_id = ''
    
    assert @outflow.invalid?
    assert_equal 4, @outflow.errors.size
    assert_equal [
      error_message_from_model(@outflow, :amount, :blank),
      error_message_from_model(@outflow, :amount, :not_a_number),
    ].sort, @outflow.errors[:amount].sort
    assert_equal [error_message_from_model(@outflow, :kind, :blank)],
      @outflow.errors[:kind]
    assert_equal [error_message_from_model(@outflow, :user_id, :blank)],
      @outflow.errors[:user_id]
  end
  
  test 'validates well formated attributes' do
    @outflow.amount = 'not number'
    
    assert @outflow.invalid?
    assert_equal 1, @outflow.errors.size
    assert_equal [error_message_from_model(@outflow, :amount, :not_a_number)],
      @outflow.errors[:amount]
    
    @outflow.amount = -957
    
    assert @outflow.invalid?
    assert_equal 1, @outflow.errors.size
    assert_equal [error_message_from_model(
      @outflow, :amount, :greater_than, count: 0
    )], @outflow.errors[:amount]
  end

  test 'refund upfronts' do
    outflow = Fabricate(:outflow, kind: 'u')

    assert_difference('Outflow.upfronts.count', -1) { assert outflow.refund! }
  end

  test 'upfronts has to have operator' do
    @outflow.kind = 'u'
    @outflow.operator_id = ''

    assert @outflow.invalid?
    assert_equal 1, @outflow.errors.size
    assert_equal [error_message_from_model(@outflow, :operator_id, :blank)],
      @outflow.errors[:operator_id]
  end

  test 'other has to have comment' do 
    @outflow.kind = 'o'
    @outflow.comment = ''

    assert @outflow.invalid?
    assert_equal 1, @outflow.errors.size
    assert_equal [error_message_from_model(@outflow, :comment, :blank)],
      @outflow.errors[:comment]
  end

  test 'pay shifts and upfronts' do
    @outflow = Fabricate(:outflow, kind: 'u', operator_id: 1)
    
    assert_difference 'Outflow.upfronts.count', -1 do
      Outflow.pay_operator_shifts_and_upfronts(
        operator_id: @outflow.operator_id, 
        start: 1.month.ago.to_date, 
        finish: Time.zone.today
      )
    end
  end

  test 'get pay pending shifts between dates' do
    shifts = Outflow.operator_pay_pending_shifts_between(
      operator_id: rand(99),
      start: 1.month.ago.to_date,
      finish: Time.zone.today,
      admin: true
    )
    
    assert_equal 15, shifts[:hours]
  end

  test 'calculate worked hours' do
    shifts = []
    @operator_shifts.each do |shift|
      shifts << OpenStruct.new(shift)
    end

    worked_hours = Outflow.worked_hours(shifts)
    assert_equal 15, worked_hours
  end
end
