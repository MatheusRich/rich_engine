# frozen_string_literal: true

module RichEngine
  class Canvas
    # A sub-section of a parent Canvas. All drawing operations are translated by
    # the slot's origin (x, y).
    class Slot < Canvas
      attr_reader :bg

      def initialize(parent, x, y, width, height, bg: nil)
        @parent = parent
        @offset_x = x
        @offset_y = y
        @width = width
        @height = height
        @bg = bg
      end

      def [](x, y)
        return nil if out_of_bounds?(x, y)
        @parent[@offset_x + x, @offset_y + y]
      end

      def []=(x, y, value)
        return if out_of_bounds?(x, y)
        @parent[@offset_x + x, @offset_y + y] = value
      end

      def clear
        fill_char = @bg || @parent.bg
        each_coord do |x, y|
          @parent[@offset_x + x, @offset_y + y] = fill_char
        end
      end

      def bg=(bg)
        @bg = bg
        clear
      end
    end
  end
end
