require 'test_helper'

class MovementTest < ActiveSupport::TestCase
  setup do
    @movement = Fabricate(:movement)

    ['pay_per_administrator_hour', 'pay_per_operator_hour'].each do |setting|
      Setting.create!(title: setting, var: setting, value: rand(100))
    end
  end

  test 'create' do
    assert_difference ['Movement.count', 'Transaction.count'] do
      assert_difference 'PaperTrail::Version.count', 2 do
        Movement.create!(
          Fabricate.attributes_for(
            :movement,
            user_id:    @movement.user_id,
            to_account_id: Provider.last.id,
            to_account_type: 'Provider'
          )
        )
      end
    end
  end

  test 'update' do
    assert_difference 'PaperTrail::Version.count' do
      assert_no_difference 'Movement.count' do
        assert @movement.update_attributes(comment: 'Updated')
      end
    end

    assert_equal 'Updated', @movement.reload.comment
  end

  test 'destroy' do
    assert_difference 'PaperTrail::Version.count' do
      assert_difference('Movement.count', -1) { @movement.destroy }
    end
  end

  test 'validates blank attributes' do
    @movement.kind = :upfront
    @movement.to_account_id = nil
    @movement.to_account_type = nil
    @movement.bill = nil # needed for provider only

    assert @movement.invalid?
    assert_equal 3, @movement.errors.size
    assert_equal [error_message_from_model(@movement, :to_account_autocomplete, :blank)],
      @movement.errors[:to_account_autocomplete]
    assert_equal [error_message_from_model(@movement, :to_account_type, :invalid)],
      @movement.errors[:to_account_type]
    assert_equal [error_message_from_model(@movement, :base, :operator_needed)],
      @movement.errors[:base]

    @movement.reload
    @movement.kind = :other
    @movement.comment = ''

    assert @movement.invalid?
    assert_equal 1, @movement.errors.size
    assert_equal [error_message_from_model(@movement, :comment, :blank)],
      @movement.errors[:comment]

    @movement.reload
    @movement.amount = ''
    @movement.kind = ''
    @movement.user_id = ''

    assert @movement.invalid?
    assert_equal 3, @movement.errors.size, @movement.errors.full_messages
    assert_equal [
      error_message_from_model(@movement, :amount, :blank),
    ].sort, @movement.errors[:amount].sort
    assert_equal [error_message_from_model(@movement, :kind, :blank)],
      @movement.errors[:kind]
    assert_equal [error_message_from_model(@movement, :user_id, :blank)],
      @movement.errors[:user_id]

    @movement.reload
    @movement.bill = '123123'
    @movement.to_account_id = nil
    @movement.to_account_type = nil

    assert @movement.invalid?
    assert_equal 3, @movement.errors.size
    assert_equal [error_message_from_model(@movement, :to_account_autocomplete, :blank)],
      @movement.errors[:to_account_autocomplete]
    assert_equal [error_message_from_model(@movement, :to_account_type, :invalid)],
      @movement.errors[:to_account_type]
    assert_equal [error_message_from_model(@movement, :base, :provider_needed_for_bill)],
      @movement.errors[:base]

    @movement.reload
    @movement.bill = nil
    @movement.kind = :tops_rings
    assert @movement.invalid?
    assert_equal 1, @movement.errors.size
    assert_equal [error_message_from_model(@movement, :bill, :blank)],
      @movement.errors[:bill]
  end

  test 'validates well formated attributes' do
    @movement.amount = 'not number'

    assert @movement.invalid?
    assert_equal 1, @movement.errors.size
    assert_equal [error_message_from_model(@movement, :amount, :not_a_number)],
      @movement.errors[:amount]
  end

  test 'refund upfronts' do
    operator = Fabricate(:operator)
    movement = Fabricate(:movement, {
      kind:                    :upfront,
      to_account_id:           operator.id,
      to_account_type:         operator.class.name,
      bill:                    nil
    })

    assert_difference('Movement.upfront.count', -1) { assert movement.refund! }
  end

  test 'other has to have comment' do
    @movement.kind = :other
    @movement.comment = ''

    assert @movement.invalid?
    assert_equal 1, @movement.errors.size
    assert_equal [error_message_from_model(@movement, :comment, :blank)],
      @movement.errors[:comment]
  end

  test 'pay shifts and upfronts' do
    skip 'Mock'

    @movement = Fabricate(:movement, kind: :upfront)

    assert_difference 'Movement.count' do
      assert_difference 'Movement.upfront.count', -1 do
        Movement.pay_operator_shifts_and_upfronts(
          operator_id: @movement.to_account_id,
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

    Movement.delete_all

    assert_difference 'Movement.count', 2 do
      Movement.pay_operator_shifts_and_upfronts(
        operator_id: 1,
        start:       1.month.ago.to_date.to_s,
        finish:      Time.zone.today.to_s,
        user_id:     Fabricate(:user).id,
        amount:      300,
        upfronts:    100
      )
    end

    operator_movements = Movement.for_operator(1)
    assert_equal 2, operator_movements.count

    # Payoff
    payoff = operator_movements.first
    assert_equal 300.0, payoff.amount.round(1)
    assert_equal :payoff, payoff.kind

    # Upfront
    upfront = operator_movements.last
    assert_equal 100, upfront.amount
    assert_equal :upfront, upfront.kind
  end

  test 'create transaction for operator' do
    operator = Fabricate(:operator)
    user     = Fabricate(:user)

    # Upfront
    m = Movement.create!(
      amount:          10,
      kind:            :upfront,
      to_account_id:   operator.id,
      to_account_type: operator.class.name,
      user_id:         user.id
    )

    assert_equal 1, m.transactions.count
    transaction = m.transactions.first

    assert_equal :debit, transaction.kind.to_sym
    assert_equal m.amount.round(2), transaction.amount.round(2)
    assert_equal operator.id, transaction.account_id

    # Payoff
    m = Movement.create!(
      amount:          10,
      kind:            :payoff,
      to_account_id:   operator.id,
      to_account_type: operator.class.name,
      user_id:         user.id
    )

    assert_equal 1, m.transactions.count
    transaction = m.transactions.first

    assert_equal :debit, transaction.kind.to_sym
    assert_equal m.amount.round(2), transaction.amount.round(2)
    assert_equal operator.id, transaction.account_id

    # Any other
    m = Movement.create!(
      amount:          10,
      kind:            :other,
      to_account_id:   operator.id,
      to_account_type: operator.class.name,
      user_id:         user.id,
      comment:         'Pay under the counter'
    )

    assert_equal 1, m.transactions.count
    transaction = m.transactions.first

    assert_equal :credit, transaction.kind.to_sym
    assert_equal m.amount.round(2), transaction.amount.round(2)
    assert_equal operator.id, transaction.account_id
  end

  test 'create transactions provider' do
    account  = Fabricate(:account)
    provider = Fabricate(:provider)
    user     = Fabricate(:user)

    m = Movement.create!(
      amount:            10,
      kind:              :paper,
      bill:              'A-11',
      from_account_id:   account.id,
      from_account_type: account.class.name,
      to_account_id:     provider.id,
      to_account_type:   provider.class.name,
      user_id:           user.id
    )

    assert_equal 2, m.transactions.count
    credit = m.transactions.first
    debit = m.transactions.last

    assert_equal :credit, credit.kind.to_sym
    assert_equal m.amount.round(2), credit.amount.round(2)
    assert_equal provider.id, credit.account_id

    assert_equal :debit, debit.kind.to_sym
    assert_equal m.amount.round(2), debit.amount.round(2)
    assert_equal account.id, debit.account_id
  end

  test 'update transactions amount' do
    operator = Fabricate(:operator)
    user     = Fabricate(:user)

    m = Movement.create!(
      amount:          10,
      kind:            :payoff,
      to_account_id:   operator.id,
      to_account_type: operator.class.name,
      user_id:         user.id
    )

    assert_equal 1, m.transactions.count
    transaction = m.transactions.first

    assert_equal 10.0, transaction.amount.to_f

    m.update!(amount: 123)

    assert_equal 123.0, transaction.reload.amount.to_f
  end
end
