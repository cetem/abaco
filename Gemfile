source 'https://rubygems.org'

gem 'rails', '~> 4.2.10'
# gem 'rails-observers', '0.1.2'

gem 'pg', '~> 0.21.0'
gem 'pg_search'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem 'paper_trail'
gem 'simple_form'
gem 'validates_timeliness'
gem 'activeresource', require: 'active_resource'
gem 'carrierwave'
gem "bugsnag"
gem 'awesome_print'
gem 'unicorn'
gem "dotiw"
gem 'google_drive', '~> 2.1.7'

gem 'sidekiq', '~> 4.2'
gem 'sinatra', require: nil
gem 'redis-namespace'

# Auth
gem 'devise', '~> 4.7'
gem 'cancan'
gem 'role_model'

# Old assets group
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'turbolinks'
gem 'byebug'

group :development do
  gem 'thin'

  # Deploy gems
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-chruby'

  # Support for ed25519 ssh keys
  gem 'ed25519'
  gem 'bcrypt_pbkdf'
end

group :test do
  gem 'selenium-webdriver', require: false
  gem 'capybara', require: false
  gem 'database_cleaner' # For Capybara
  gem 'fabrication'
  gem 'faker'
  gem 'webmock'
end
