# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter %r{^/test/}
end

require 'bundler/setup'
Bundler.require(:default, :test)

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'file_structure'

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
