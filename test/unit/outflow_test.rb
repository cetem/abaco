require 'test_helper'

class OutflowTest < ActiveSupport::TestCase
  setup do
    @outflow = Fabricate(:outflow)
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
    assert_equal [error_message_from_model(@outflow, :amount, :greater_than,
        count: 0)], @outflow.errors[:amount]
  end
end
