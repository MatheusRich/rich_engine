# frozen_string_literal: true

require "test_helper"

class EnumMixinTest < Minitest::Test
  def test_that_it_creates_accessors_for_enum_and_enum_value
    monster_class = Class.new do
      include RichEngine::Enum::Mixin

      enum :size, [:small, :medium, :large]

      def initialize(size:)
        @size = size
      end
    end

    m1 = monster_class.new(size: :small)

    assert m1.size.small?
    assert_instance_of RichEngine::Enum::Value, m1.size
    assert_instance_of RichEngine::Enum, monster_class.sizes
  end

  def test_that_it_allows_creating_enum_with_custom_name
    monster_class = Class.new do
      include RichEngine::Enum::Mixin

      enum :size, [:small, :medium, :large], enum_name: "types"

      def initialize(size:)
        @size = size
      end
    end

    assert_instance_of RichEngine::Enum, monster_class.types
  end
end
