# frozen_string_literal: true

module RichEngine
  class Canvas
    # A sub-section of a parent Canvas. All drawing operations are translated by
    # the slot's origin (x, y).
    class Slot < Canvas
      # @return [String, nil] the slot's background fill, or nil to inherit the
      #   parent's
      attr_reader :bg

      # @param parent [RichEngine::Canvas] the canvas this slot draws onto
      # @param x [Integer] the slot's left column on the parent canvas
      # @param y [Integer] the slot's top row on the parent canvas
      # @param width [Integer] the slot width
      # @param height [Integer] the slot height
      # @param bg [String, nil] the slot's background fill, or nil to inherit
      #   the parent's
      def initialize(parent, x, y, width, height, bg: nil)
        @parent = parent
        @offset_x = x
        @offset_y = y
        @width = width
        @height = height
        @bg = bg
      end

      # Read the cell at the slot-local (x, y), translated to parent space.
      #
      # @param x [Integer] the slot-local column
      # @param y [Integer] the slot-local row
      # @return [String, nil] the cell contents, or nil if out of the slot's
      #   bounds
      def [](x, y)
        return nil if out_of_bounds?(x, y)
        @parent[@offset_x + x, @offset_y + y]
      end

      # Write the cell at the slot-local (x, y), translated to parent space.
      # Writes outside the slot are clipped.
      #
      # @param x [Integer] the slot-local column
      # @param y [Integer] the slot-local row
      # @param value [String] the cell contents to write
      # @return [void]
      def []=(x, y, value)
        return if out_of_bounds?(x, y)
        @parent[@offset_x + x, @offset_y + y] = value
      end

      # Clear the slot, filling it with its background (or the parent's if the
      # slot has none).
      #
      # @return [void]
      def clear
        fill_char = @bg || @parent.bg
        each_coord do |x, y|
          self[x, y] = fill_char
        end
      end

      # Change the slot's background fill character and clear the slot.
      #
      # @param bg [String] the new background fill character
      # @return [void]
      def bg=(bg)
        @bg = bg
        clear
      end
    end
  end
end
