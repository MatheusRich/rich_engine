# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'rich_engine'
require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]
