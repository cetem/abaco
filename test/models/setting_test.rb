require 'test_helper'

class SettingTest < ActiveSupport::TestCase
  def setup
    @setting = Fabricate(:setting)
  end

  test 'create' do
    assert_difference ['Setting.count', 'PaperTrail::Version.count'] do
      Setting.create! Fabricate.attributes_for(:setting)
    end
  end

  test 'update' do
    assert_difference 'PaperTrail::Version.count' do
      assert_no_difference 'Setting.count' do
        assert @setting.update_attributes(value: '101')
      end
    end

    assert_equal '101', @setting.reload.value
  end

  test 'destroy' do
    assert_difference 'PaperTrail::Version.count' do
      assert_difference('Setting.count', -1) { @setting.destroy }
    end
  end

  test 'validates blank attributes' do
    @setting.title = ''
    @setting.value = ''

    assert @setting.invalid?
    assert_equal 2, @setting.errors.size
    assert_equal [error_message_from_model(@setting, :title, :blank)],
      @setting.errors[:title]
    assert_equal [error_message_from_model(@setting, :value, :blank)],
      @setting.errors[:value]
  end

  test 'validates unique attributes' do
    new_setting = Fabricate(:setting)
    @setting.var = new_setting.var

    assert @setting.invalid?
    assert_equal 1, @setting.errors.size
    assert_equal [error_message_from_model(@setting, :var, :taken)],
      @setting.errors[:var]
  end
end
