# frozen_string_literal: true

require_relative "string_colors"
require_relative "canvas/slot"

module RichEngine
  # A 2D character grid that you draw to each frame, with colored text and
  # shapes. Cells are stored row-major in a flat array.
  class Canvas
    using StringColors

    # @return [Array<String>] the flat, row-major array of cell contents
    # @return [String] the background fill character
    # @return [Integer] the canvas width in characters
    # @return [Integer] the canvas height in characters
    attr_reader :canvas, :bg, :width, :height

    # @param width [Integer] the canvas width in characters
    # @param height [Integer] the canvas height in characters
    # @param bg [String] the background fill character
    def initialize(width, height, bg: " ")
      @width = width
      @height = height
      @bg = bg
      clear
    end

    # The canvas dimensions as a [width, height] pair.
    #
    # @return [Array(Integer, Integer)] the width and height
    def dimensions
      [@width, @height]
    end

    # Yield every (x, y) coordinate in the canvas.
    #
    # @yieldparam x [Integer] the column
    # @yieldparam y [Integer] the row
    # @return [void]
    def each_coord(&block)
      (0...@width).each do |x|
        (0...@height).each do |y|
          block.call(x, y)
        end
      end
    end

    # Enumerate the canvas one row at a time.
    #
    # @return [Enumerator] an enumerator of rows, each an array of cells
    def rows
      @canvas.each_slice(@width)
    end

    # Draw a multi-line string as a sprite; spaces are treated as transparent
    # and left untouched.
    #
    # @param sprite [String] the multi-line sprite to draw
    # @param x [Integer] the left column to start drawing at
    # @param y [Integer] the top row to start drawing at
    # @param fg [Symbol, String, Array<Integer>, Integer] the foreground color
    # @param bg [Symbol, String, Array<Integer>, Integer] the background color
    # @return [void]
    def draw_sprite(sprite, x: 0, y: 0, fg: :white, bg: :transparent)
      sprite.split("\n").each.with_index do |line, i|
        line.each_char.with_index do |char, j|
          next if char == " "

          self[x + j, y + i] = char.fg(fg).bg(bg)
        end
      end
    end

    # Write colored text at a position. Pass :center for x or y to center the
    # text along that axis. A single color applies to every character; an array
    # of colors cycles per character.
    #
    # @param str [String] the text to write
    # @param x [Integer, Symbol] the left column, or :center to horizontally
    #   center the text
    # @param y [Integer, Symbol] the row, or :center to vertically center the
    #   text
    # @param fg [Symbol, String, Array<Integer>, Integer, Array] the foreground
    #   color, or an array of color specs to cycle per character
    # @param bg [Symbol, String, Array<Integer>, Integer, Array] the background
    #   color, or an array of color specs to cycle per character
    # @return [void]
    # @example Cycle foreground colors per character
    #   canvas.write_string("Hello", x: :center, y: 1, fg: [:red, :green, :blue])
    def write_string(str, x: 0, y: 0, fg: :white, bg: :transparent)
      if x == :center
        x = (@width - str.length) / 2
      end

      if y == :center
        y = (@height - 1) / 2
      end

      fg = Array(fg).cycle
      bg = Array(bg).cycle

      str.to_s.each_char.with_index do |char, i|
        self[x + i, y] = char.fg(fg.next).bg(bg.next)
      end
    end

    # Draw a filled rectangle. Coordinates and sizes are rounded to integers.
    #
    # @param x [Integer] the left column
    # @param y [Integer] the top row
    # @param width [Integer] the rectangle width
    # @param height [Integer] the rectangle height
    # @param char [String] the character to fill with
    # @param color [Symbol, String, Array<Integer>, Integer] the fill color
    # @return [void]
    def draw_rect(x:, y:, width:, height:, char: "█", color: :white)
      x = x.round
      y = y.round
      width = width.round
      height = height.round

      (x..(x + width - 1)).each do |x_pos|
        (y..(y + height - 1)).each do |y_pos|
          self[x_pos, y_pos] = char.fg(color)
        end
      end
    end

    # Draw a filled circle centered on (x, y). The center is rounded to
    # integers.
    #
    # @param x [Integer] the center column
    # @param y [Integer] the center row
    # @param radius [Integer] the circle radius
    # @param char [String] the character to fill with
    # @param color [Symbol, String, Array<Integer>, Integer] the fill color
    # @return [void]
    def draw_circle(x:, y:, radius:, char: "█", color: :white)
      x = x.round
      y = y.round

      (x - radius..x + radius).each do |x_pos|
        (y - radius..y + radius).each do |y_pos|
          next if (x_pos - x)**2 + (y_pos - y)**2 > radius**2

          self[x_pos, y_pos] = char.fg(color)
        end
      end
    end

    # Whether the given coordinate falls outside the canvas.
    #
    # @param x [Integer] the column
    # @param y [Integer] the row
    # @return [Boolean] true if (x, y) is outside the canvas bounds
    def out_of_bounds?(x, y)
      return true if x < 0
      return true if x >= @width
      return true if y < 0
      return true if y >= @height

      false
    end

    # Read the cell at (x, y). Coordinates are rounded to integers.
    #
    # @param x [Integer] the column
    # @param y [Integer] the row
    # @return [String, nil] the cell contents
    def [](x, y)
      x = x.round
      y = y.round

      @canvas[at(x, y)]
    end

    # Write a cell at (x, y), ignoring out-of-bounds writes. Coordinates are
    # rounded to integers.
    #
    # @param x [Integer] the column
    # @param y [Integer] the row
    # @param value [String] the cell contents to write
    # @return [void]
    def []=(x, y, value)
      x = x.round
      y = y.round
      return if out_of_bounds?(x, y)

      @canvas[at(x, y)] = value
    end

    # Clear the entire canvas, resetting every cell to the background fill.
    #
    # @return [void]
    def clear
      @canvas = create_blank_canvas
    end

    # Change the background fill character and clear the canvas.
    #
    # @param bg [String] the new background fill character
    # @return [void]
    def bg=(bg)
      @bg = bg
      clear
    end

    # Define a logical sub-region of this canvas that translates local
    # coordinates into the parent canvas space and clips drawing to the region.
    #
    # @param x [Integer] the region's left column on the parent canvas
    # @param y [Integer] the region's top row on the parent canvas
    # @param width [Integer] the region width
    # @param height [Integer] the region height
    # @param bg [String, nil] the slot's background fill, or nil to inherit the
    #   parent's
    # @return [RichEngine::Canvas::Slot] the sub-region canvas
    # @example
    #   log = canvas.slot(x: 80, y: 0, width: 20, height: 10)
    #   log.write_string("Hello", x: 1, y: 1)  # => writes at (81, 1)
    def slot(x:, y:, width:, height:, bg: nil)
      Slot.new(self, x, y, width, height, bg: bg)
    end

    private

    def at(x, y)
      y * @width + x
    end

    def create_blank_canvas
      (0...(@width * @height)).map { @bg }
    end
  end
end
