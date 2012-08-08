require 'test_helper'

class OperatorTest < ActiveSupport::TestCase
  test 'should connect to print_hub' do
    assert Operator.find(1)
    assert_response :success
  end
end
