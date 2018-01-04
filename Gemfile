source 'https://rubygems.org'

gem 'rails', '~> 4.2'
# gem 'rails-observers', '0.1.2'

gem 'pg'
gem 'will_paginate'
gem 'paper_trail'
gem 'magick_columns', github: 'kainlite/magick_columns'
gem 'simple_form'
gem 'validates_timeliness'
gem 'activeresource', require: 'active_resource'
gem 'carrierwave'
gem "bugsnag"
gem 'awesome_print'
gem 'unicorn'
gem "dotiw"
gem 'google_drive' #, '1.0.6'

gem 'sidekiq', '~> 4.2'
gem 'sinatra', require: nil
gem 'redis-namespace'

# Auth
gem 'devise', '~> 4.3'
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
end

group :test do
  gem 'selenium-webdriver', require: false
  gem 'capybara', require: false
  gem 'database_cleaner' # For Capybara
  gem 'fabrication'
  gem 'faker'
  gem 'webmock'
end
