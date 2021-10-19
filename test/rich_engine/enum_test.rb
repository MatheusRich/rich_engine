# frozen_string_literal: true

require "test_helper"

class EnumTest < Minitest::Test
  def test_that_enum_has_name
    enum = RichEngine::Enum.new(:colors, [:red, :green, :blue])
    assert_equal(:colors, enum.name)

    enum = RichEngine::Enum.new(:directions, up: 0, down: 1, left: 2, right: 3)
    assert_equal(:directions, enum.name)
  end

  def test_that_enum_has_options
    enum = RichEngine::Enum.new(:colors, [:red, :green, :blue])
    assert_equal({red: 0, green: 1, blue: 2}, enum.options)

    enum = RichEngine::Enum.new(:directions, up: 0, down: 1, left: 2, right: 3)
    assert_equal({up: 0, down: 1, left: 2, right: 3}, enum.options)
  end

  def test_that_enum_defines_methods_for_each_value
    enum = RichEngine::Enum.new(:colors, [:red, :green, :blue])
    assert_instance_of(RichEngine::Enum::Value, enum.red)
    assert_instance_of(RichEngine::Enum::Value, enum.green)
    assert_instance_of(RichEngine::Enum::Value, enum.blue)

    enum = RichEngine::Enum.new(:directions, up: 0, down: 1, left: 2, right: 3)
    assert_instance_of(RichEngine::Enum::Value, enum.up)
    assert_instance_of(RichEngine::Enum::Value, enum.down)
    assert_instance_of(RichEngine::Enum::Value, enum.left)
    assert_instance_of(RichEngine::Enum::Value, enum.right)
  end

  def test_that_enum_does_not_define_methods_in_the_base_class
    enum = RichEngine::Enum.new(:colors, [:red])

    assert_raises NoMethodError do
      enum.class.red
    end

    enum = RichEngine::Enum.new(:directions, up: 0)

    assert_raises NoMethodError do
      enum.class.up
    end
  end
end
