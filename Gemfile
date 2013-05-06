source 'https://rubygems.org'

gem 'rails', '4.0.0.rc1'

gem 'pg'
gem 'jquery-rails'
gem 'turbolinks'
gem 'will_paginate'
gem 'simple_form', '~> 3.0.0.beta1'
gem 'devise', github: 'plataformatec/devise', branch: 'rails4'
gem 'cancan'
gem 'role_model'
gem 'paper_trail', github: 'airblade/paper_trail', branch: 'rails4'
gem 'magick_columns', github: 'kainlite/magick_columns'
gem 'validates_timeliness'
gem 'sidekiq'
gem 'capistrano'
gem 'activeresource', '4.0.0.beta1', require: 'active_resource'

# Assets Group =)
gem 'sass-rails', '~> 4.0.0.rc1'
gem 'coffee-rails', '~> 4.0.0.rc1'
gem 'uglifier', '>= 1.3.0'

group :development do
  gem 'thin'
end

group :test do
  gem 'turn'
  gem 'minitest'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'database_cleaner' # For Capybara
  gem 'fabrication'
  gem 'faker'
  gem 'webmock'
end

if ENV['TRAVIS']
  gem 'test-unit' # For Travis errors
end
