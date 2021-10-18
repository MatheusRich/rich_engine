# frozen_string_literal: true

require "test_helper"

class EnumTest < Minitest::Test
  def test_that_enum_has_name
    enum = RichEngine::Enum.new(colors: [:red, :green, :blue])
    assert_equal(:colors, enum.name)

    enum = RichEngine::Enum.new(directions: [:up, :down, :left, :right])
    assert_equal(:directions, enum.name)
  end

  def test_that_enum_has_values
    enum = RichEngine::Enum.new(colors: [:red, :green, :blue])
    assert_equal({red: 0, green: 1, blue: 2}, enum.values)

    enum = RichEngine::Enum.new(directions: [:up, :down, :left, :right])
    assert_equal({up: 0, down: 1, left: 2, right: 3}, enum.values)
  end

  def test_that_enum_defines_methods_for_each_value
    enum = RichEngine::Enum.new(colors: [:red, :green, :blue])
    assert_equal(0, enum.red)
    assert_equal(1, enum.green)
    assert_equal(2, enum.blue)

    enum = RichEngine::Enum.new(directions: [:up, :down, :left, :right])
    assert_equal(0, enum.up)
    assert_equal(1, enum.down)
    assert_equal(2, enum.left)
    assert_equal(3, enum.right)
  end

  def test_that_enum_does_not_define_methods_in_the_base_class
    enum = RichEngine::Enum.new(colors: [:red])

    assert_raises NoMethodError do
      enum.class.red
    end

    enum = RichEngine::Enum.new(directions: [:up])

    assert_raises NoMethodError do
      enum.class.up
    end
  end

  def test_that_enum_raises_error_if_multiple_keys_are_given
    error = assert_raises(ArgumentError) do
      RichEngine::Enum.new(colors: [:red, :green, :blue], other_colors: [:yellow, :brown, :orange])
    end

    assert_match(%r{You must provide exactly 1 key/value pair}, error.message)
  end

  def test_that_enum_raises_error_if_no_key_is_given
    error = assert_raises(ArgumentError) do
      RichEngine::Enum.new({})
    end

    assert_match(%r{You must provide exactly 1 key/value pair}, error.message)
  end
end
