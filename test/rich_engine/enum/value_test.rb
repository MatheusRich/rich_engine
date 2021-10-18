# frozen_string_literal: true

require "test_helper"

class EnumValueTest < Minitest::Test
  def test_that_it_creates_query_methods_for_enum_options
    enum_red = RichEngine::Enum::Value.new(options: [:red, :green, :blue], selected: :red)
    enum_green = RichEngine::Enum::Value.new(options: [:red, :green, :blue], selected: :green)
    enum_blue = RichEngine::Enum::Value.new(options: [:red, :green, :blue], selected: :blue)

    assert enum_red.red?
    refute enum_red.green?
    refute enum_red.blue?

    assert enum_green.green?
    refute enum_green.red?
    refute enum_green.blue?

    assert enum_blue.blue?
    refute enum_blue.red?
    refute enum_blue.green?
  end

  def test_equality
    enum_red = RichEngine::Enum::Value.new(options: [:red, :green, :blue], selected: :red)
    enum_red = RichEngine::Enum::Value.new(options: [:red, :green, :blue], selected: :red)
    enum_green = RichEngine::Enum::Value.new(options: [:red, :green, :blue], selected: :green)

    enum_red
  end

  def test_that_it_raises_error_on_unknown_enum_value
    error = assert_raises(ArgumentError) do
      RichEngine::Enum::Value.new(options: [:red, :green, :blue], selected: :unknown_value)
    end

    assert_match("Unknown enum value `unknown_value`. Options are `[:red, :green, :blue]`", error.message)
  end
end
