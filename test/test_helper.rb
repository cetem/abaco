ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'
require 'capybara/rails'
require 'capybara/minitest'
require 'capybara-screenshot/minitest'
require 'capybara/poltergeist'


class ActiveSupport::TestCase
  fixtures :all

  include WebMock::API
  # Add more helper methods to be used by all tests here...

  setup do
    WebMock.enable!

    instance_eval(File.read(Rails.root.join('test/lib/stub_requests.rb')))
  end

  def error_message_from_model(model, attribute, message, extra = {})
    ::ActiveModel::Errors.new(model).generate_message(attribute, message, extra)
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include WebMock::API
  # Add more helper methods to be used by all tests here...

  setup do
    WebMock.enable!

    instance_eval(File.read(Rails.root.join('test/lib/stub_requests.rb')))
  end
end

# Transactional fixtures do not work with Selenium tests, because Capybara
# uses a separate server thread, which the transactions would be hidden
# from. We hence use DatabaseCleaner to truncate our test database.
DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  include Capybara::Minitest::Assertions
  include Capybara::Screenshot::MiniTestPlugin

  RUN_WITH_GUI = ENV['local'] || false

  # Stop ActiveRecord from wrapping tests in transactions
  # self.use_transactional_fixtures = false
  Capybara.server = :webrick
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {
      inspector: true,
      js_errors: true,
      window_size: [1600, 1200]
    })
  end

if ENV['TRAVIS']
    require 'jsonclient'
    require 'base64'

    Capybara::Screenshot.after_save_screenshot do |path|
      auth = { 'Authorization' => 'Bearer ' + "424871e2662f85351c735361fa763d7276b25518"}
      body = {image: Base64.encode64(File.read(path))}
      rsp = JSONClient.new.post('https://api.imgur.com/3/image', body, auth).body
      puts "\n======== IMG ========"
      puts "\n"
      puts rsp['data']['link']
      puts "\n"
      puts "\n"
    end
  end

  Capybara.javascript_driver = RUN_WITH_GUI ? :selenium : :poltergeist

  Capybara.current_driver = Capybara.javascript_driver
  Capybara.server_port = '5416' + (ENV['TEST_ENV_NUMBER'] || 9).to_s
  Capybara.default_max_wait_time = 3

  setup do
    WebMock.disable!

    Capybara.server_host = 'localhost'
    Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"
    Capybara.reset!    # Forget the (simulated) browser state

    if RUN_WITH_GUI
      Capybara.page.driver.browser.manage.window.maximize
    else
      Capybara.page.driver.resize(1600, 1200)
    end
  end

  teardown do
    # Truncate the database
    DatabaseCleaner.clean
    # Forget the (simulated) browser state
    Capybara.reset_sessions!
  end

  def login
    user = Fabricate(:user, password: '123456')

    visit new_user_session_path

    assert_page_has_no_errors!

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: '123456'

    find('.btn-primary.submit').click

    assert_equal movements_path, current_path

    assert_page_has_no_errors!
    assert page.has_css?('.alert.alert-info')

    within '.alert.alert-info' do
      assert page.has_content?(I18n.t('devise.sessions.signed_in'))
    end
  end

  def assert_page_has_no_errors!
    sleep 0.5
    assert page.has_no_css?('#unexpected_error')
  end
end
