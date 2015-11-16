source 'https://rubygems.org'

gem 'rails', '4.2.4'

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

# Auth
gem 'devise'
gem 'cancan'
gem 'role_model'

# Old assets group
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'turbolinks'
gem 'pry-nav'

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
