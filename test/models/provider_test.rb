require 'test_helper'

class ProviderTest < ActiveSupport::TestCase
  def setup
    @provider = Fabricate(:provider)
  end

  test 'create' do
    assert_difference ['Provider.count', 'PaperTrail::Version.count'] do
      @provider = Provider.create(Fabricate.attributes_for(:provider))
    end
  end

  test 'update' do
    assert_difference 'PaperTrail::Version.count' do
      assert_no_difference 'Provider.count' do
        assert @provider.update_attributes(name: 'Updated')
      end
    end

    assert_equal 'Updated', @provider.reload.name
  end

  test 'destroy' do
    assert_difference 'PaperTrail::Version.count' do
      assert_difference('Provider.count', -1) { @provider.destroy }
    end
  end

  test 'validates blank attributes' do
    @provider.name = ''

    assert @provider.invalid?
    assert_equal 1, @provider.errors.size
    assert_equal [error_message_from_model(@provider, :name, :blank)],
      @provider.errors[:name]
  end

  test 'validates unique attributes' do
    new_provider = Fabricate(:provider)
    @provider.name = new_provider.name

    assert @provider.invalid?
    assert_equal 1, @provider.errors.size
    assert_equal [error_message_from_model(@provider, :name, :detailed_taken)],
      @provider.errors[:name]
  end
end
