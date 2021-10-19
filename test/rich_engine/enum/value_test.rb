# frozen_string_literal: true

require "test_helper"

class EnumValueTest < Minitest::Test
  def test_that_it_creates_query_methods_for_enum_options
    enum = RichEngine::Enum.new(:colors, red: 0, green: 1, blue: 2)
    enum_red = RichEngine::Enum::Value.new(enum: enum, selected: :red)
    enum_green = RichEngine::Enum::Value.new(enum: enum, selected: :green)
    enum_blue = RichEngine::Enum::Value.new(enum: enum, selected: :blue)

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

  def test_that_it_has_value
    enum = RichEngine::Enum.new(:colors, red: 0, green: 1, blue: 2)
    enum_red = RichEngine::Enum::Value.new(enum: enum, selected: :red)
    enum_green = RichEngine::Enum::Value.new(enum: enum, selected: :green)
    enum_blue = RichEngine::Enum::Value.new(enum: enum, selected: :blue)

    assert_equal 0, enum_red.value
    assert_equal 1, enum_green.value
    assert_equal 2, enum_blue.value
  end

  def test_that_it_can_compare_values_from_the_same_enum
    enum = RichEngine::Enum.new(:colors, red: 0, green: 1, blue: 2)
    enum_red = RichEngine::Enum::Value.new(enum: enum, selected: :red)
    enum_green = RichEngine::Enum::Value.new(enum: enum, selected: :green)
    enum_blue = RichEngine::Enum::Value.new(enum: enum, selected: :blue)

    assert enum_red < enum_green && enum_green < enum_blue
  end

  def test_that_it_cant_compare_values_from_different_enums
    enum1 = RichEngine::Enum.new(:colors, red: 0, green: 1, blue: 2)
    enum1_red = RichEngine::Enum::Value.new(enum: enum1, selected: :red)
    enum2 = RichEngine::Enum.new(:other, red: 0, green: 1, blue: 2)
    enum2_red = RichEngine::Enum::Value.new(enum: enum2, selected: :red)

    assert_raises_error(ArgumentError, "Can't compare values from different enums") do
      assert enum1_red < enum2_red
    end
  end

  def test_equality
    enum1 = RichEngine::Enum.new(:colors, red: 0, green: 1, blue: 2)
    enum1_red = RichEngine::Enum::Value.new(enum: enum1, selected: :red)
    enum1_blue = RichEngine::Enum::Value.new(enum: enum1, selected: :blue)
    enum1_red2 = RichEngine::Enum::Value.new(enum: enum1, selected: :red)

    assert enum1_red == enum1_red2
    assert enum1_red != enum1_blue
  end

  def test_that_same_value_from_different_enums_arent_equal
    enum1 = RichEngine::Enum.new(:colors, red: 0, green: 1, blue: 2)
    enum2 = RichEngine::Enum.new(:traffic_lights, red: 0, green: 1, blue: 2)
    enum1_red = RichEngine::Enum::Value.new(enum: enum1, selected: :red)
    enum2_red = RichEngine::Enum::Value.new(enum: enum2, selected: :red)

    assert enum1_red != enum2_red
  end

  def test_that_same_value_with_different_name_on_same_enum_arent_equal
    enum = RichEngine::Enum.new(:colors, red: 0, green: 0, blue: 0)
    enum_red = RichEngine::Enum::Value.new(enum: enum, selected: :red)
    enum_blue = RichEngine::Enum::Value.new(enum: enum, selected: :blue)
    enum_green = RichEngine::Enum::Value.new(enum: enum, selected: :green)

    assert enum_red != enum_blue
    assert enum_red != enum_green
    assert enum_blue != enum_green
  end

  def test_that_it_raises_error_on_unknown_enum_value
    msg = "Unknown enum value `unknown_value`. Options are `[:red, :green, :blue]`"

    assert_raises_error(ArgumentError, msg) do
      enum = RichEngine::Enum.new(:colors, red: 0, green: 1, blue: 2)
      RichEngine::Enum::Value.new(enum: enum, selected: :unknown_value)
    end
  end
end
