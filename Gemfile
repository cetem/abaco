source 'https://rubygems.org'

gem 'rails', '4.0.2'

gem 'pg'
gem 'will_paginate'
gem 'paper_trail'
gem 'magick_columns', github: 'kainlite/magick_columns'
gem 'simple_form'
gem 'validates_timeliness'
gem 'activeresource', require: 'active_resource'
gem 'newrelic_rpm'

# Deploy gems
gem 'capistrano'
gem 'capistrano-rails'
gem 'capistrano-bundler'

# Auth & Mailing Gems
gem 'devise'
gem 'devise-async'
gem 'cancan'
gem 'role_model'
gem 'sidekiq'

# Old assets group
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'turbolinks'

group :development do
  gem 'thin'
end

group :test do
  gem 'turn'
  gem 'selenium-webdriver', require: false
  gem 'capybara', require: false
  gem 'database_cleaner' # For Capybara
  gem 'fabrication'
  gem 'faker'
  gem 'webmock'
end
