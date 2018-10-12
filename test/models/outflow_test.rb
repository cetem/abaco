require 'test_helper'

class OutflowTest < ActiveSupport::TestCase
  setup do
    @outflow = Fabricate(:outflow)

    ['pay_per_administrator_hour', 'pay_per_operator_hour'].each do |setting|
      Setting.create!(title: setting, var: setting, value: rand(100))
    end
  end

  test 'create' do
    assert_difference ['Outflow.count', 'PaperTrail::Version.count'] do
      Outflow.create!(
        Fabricate.attributes_for(
          :outflow,
          user_id:     @outflow.user_id,
          operator_id: @outflow.user_id,
          provider_id: @outflow.provider_id
        )
      )
    end
  end

  test 'update' do
    assert_difference 'PaperTrail::Version.count' do
      assert_no_difference 'Outflow.count' do
        assert @outflow.update_attributes(comment: 'Updated')
      end
    end

    assert_equal 'Updated', @outflow.reload.comment
  end

  test 'destroy' do
    assert_difference 'PaperTrail::Version.count' do
      assert_difference('Outflow.count', -1) { @outflow.destroy }
    end
  end

  test 'validates blank attributes' do
    @outflow.kind = 'u'
    @outflow.operator_id = ''

    assert @outflow.invalid?
    assert_equal 1, @outflow.errors.size
    assert_equal [error_message_from_model(@outflow, :auto_operator_name, :blank)],
      @outflow.errors[:auto_operator_name]

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
    assert_equal 3, @outflow.errors.size, @outflow.errors.full_messages
    assert_equal [
      error_message_from_model(@outflow, :amount, :blank),
    ].sort, @outflow.errors[:amount].sort
    assert_equal [error_message_from_model(@outflow, :kind, :blank)],
      @outflow.errors[:kind]
    assert_equal [error_message_from_model(@outflow, :user_id, :blank)],
      @outflow.errors[:user_id]

    @outflow.reload
    @outflow.bill = '123123'
    @outflow.provider = nil

    assert @outflow.invalid?
    assert_equal 1, @outflow.errors.size
    assert_equal [error_message_from_model(@outflow, :auto_provider_name, :blank)],
      @outflow.errors[:auto_provider_name]

    @outflow.reload
    @outflow.bill = nil
    @outflow.kind = 'q'
    assert @outflow.invalid?
    assert_equal 1, @outflow.errors.size
    assert_equal [error_message_from_model(@outflow, :bill, :blank)],
      @outflow.errors[:bill]
  end

  test 'validates well formated attributes' do
    @outflow.amount = 'not number'

    assert @outflow.invalid?
    assert_equal 1, @outflow.errors.size
    assert_equal [error_message_from_model(@outflow, :amount, :not_a_number)],
      @outflow.errors[:amount]
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
    assert_equal [error_message_from_model(@outflow, :auto_operator_name, :blank)],
      @outflow.errors[:auto_operator_name]
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
    skip 'Mock'

    @outflow = Fabricate(:outflow, kind: 'u', operator_id: 1)

    assert_difference 'Outflow.count' do
      assert_difference 'Outflow.upfronts.count', -1 do
        Outflow.pay_operator_shifts_and_upfronts(
          operator_id: @outflow.operator_id,
          start:       1.month.ago.to_date.to_s,
          finish:      Time.zone.today.to_s,
          user_id:     Fabricate(:user).id,
          amount:      300
        )
      end
    end
  end

  test 'pay shifts and upfronts with another upfront' do
    skip 'Mock'

    Outflow.delete_all

    assert_difference 'Outflow.count', 2 do
      Outflow.pay_operator_shifts_and_upfronts(
        operator_id: 1,
        start:       1.month.ago.to_date.to_s,
        finish:      Time.zone.today.to_s,
        user_id:     Fabricate(:user).id,
        amount:      300,
        upfronts:    100
      )
    end

    operator_outflows = Outflow.for_operator(1)
    assert_equal 2, operator_outflows.count

    # Payoff
    payoff = operator_outflows.first
    assert_equal 300.0, payoff.amount.round(1)
    assert_equal Outflow::KIND[:payoff], payoff.kind

    # Upfront
    upfront = operator_outflows.last
    assert_equal 100, upfront.amount
    assert_equal Outflow::KIND[:upfront], upfront.kind
  end
end
