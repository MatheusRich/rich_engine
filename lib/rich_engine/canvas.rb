# frozen_string_literal: true

require_relative "string_colors"
require_relative "canvas/slot"

module RichEngine
  class Canvas
    using StringColors

    attr_reader :canvas, :bg

    def initialize(width, height, bg: " ")
      @width = width
      @height = height
      @bg = bg
      clear
    end

    def dimensions
      [@width, @height]
    end

    def each_coord(&block)
      (0...@width).each do |x|
        (0...@height).each do |y|
          block.call(x, y)
        end
      end
    end

    def rows
      @canvas.each_slice(@width)
    end

    def draw_sprite(sprite, x: 0, y: 0, fg: :white)
      sprite.split("\n").each.with_index do |line, i|
        line.each_char.with_index do |char, j|
          next if char == " "

          self[x + j, y + i] = char.fg(fg)
        end
      end
    end

    def write_string(str, x: 0, y: 0, fg: :white, bg: :transparent)
      if x == :center
        x = (@width - str.length) / 2
      end

      if y == :center
        y = (@height - str.length) / 2
      end

      fg = Array(fg).cycle
      bg = Array(bg).cycle

      str.to_s.each_char.with_index do |char, i|
        self[x + i, y] = char.fg(fg.next).bg(bg.next)
      end
    end

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

    def out_of_bounds?(x, y)
      return true if x < 0
      return true if x >= @width
      return true if y < 0
      return true if y >= @height

      false
    end

    def [](x, y)
      x = x.round
      y = y.round

      @canvas[at(x, y)]
    end

    def []=(x, y, value)
      x = x.round
      y = y.round
      return if out_of_bounds?(x, y)

      @canvas[at(x, y)] = value
    end

    def clear
      @canvas = create_blank_canvas
    end

    def bg=(bg)
      @bg = bg
      clear
    end

    # Define a logical sub-region of this canvas that translates local
    # coordinates into the parent canvas space.
    #
    # Example:
    #   log = canvas.slot(x: 80, y: 0, width: 20, height: 10)
    #   log.write_string("Hello", x: 1, y: 1)  # => writes at (81, 1)
    #
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
