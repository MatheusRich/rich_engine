# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  enable_coverage :branch

  add_filter "/test/"
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "rich_engine"
require "minitest/autorun"
require "minitest/focus"
require "minitest/reporters"

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

def assert_raises_error(exception, msg)
  error = assert_raises(exception) do
    yield
  end

  assert_match(msg, error.message)
end
