# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :development do
  gem 'rake', '~> 13.0'
  gem 'rubocop', '~> 1.21', require: false
  gem 'rubocop-minitest', '~> 0.17.2', require: false
  gem 'rubocop-performance', '~> 1.13', require: false
  gem 'rubocop-rake', '~> 0.6.0', require: false
  gem 'yard', '~> 0.9.27', require: false
end

group :test do
  gem 'minitest', '~> 5.0'
  gem 'minitest-reporters', '~> 1.5'
  gem 'simplecov', '~> 0.21.2', require: false
end

group :development, :test do
  gem 'debug', '~> 1.4'
end
