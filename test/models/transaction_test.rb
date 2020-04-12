require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  def setup
    skip
    @transaction = Fabricate(:transaction)
  end

  test 'create' do
    assert_difference ['Transaction.count', 'PaperTrail::Version.count'] do
      @transaction = Transaction.create(Fabricate.attributes_for(:transaction))
    end
  end

  test 'update' do
    assert_difference 'PaperTrail::Version.count' do
      assert_no_difference 'Transaction.count' do
        assert @transaction.update(attr: 'Updated')
      end
    end

    assert_equal 'Updated', @transaction.reload.attr
  end

  test 'destroy' do
    assert_difference 'PaperTrail::Version.count' do
      assert_difference('Transaction.count', -1) { @transaction.destroy }
    end
  end

  test 'validates blank attributes' do
    @transaction.attr = ''

    assert @transaction.invalid?
    assert_equal 1, @transaction.errors.size
    assert_equal [error_message_from_model(@transaction, :attr, :blank)],
      @transaction.errors[:attr]
  end

  test 'validates unique attributes' do
    new_transaction = Fabricate(:transaction)
    @transaction.attr = new_transaction.attr

    assert @transaction.invalid?
    assert_equal 1, @transaction.errors.size
    assert_equal [error_message_from_model(@transaction, :attr, :taken)],
      @transaction.errors[:attr]
  end
end
