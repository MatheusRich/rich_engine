# frozen_string_literal: true

require_relative "string_colors"

module RichEngine
  class Canvas
    using StringColors

    attr_reader :canvas

    def initialize(width, height, bg: ' ')
      @width = width
      @height = height
      @bg = bg
      @canvas = create_blank_canvas
    end

    def dimentions
      [@width, @height]
    end

    def write_string(str, x: 0, y: 0, fg: :white, bg: :transparent)
      fg = Array(fg).cycle
      bg = Array(bg).cycle

      str.to_s.each_char.with_index do |char, i|
        self[x + i, y] = char.fg(fg.next).bg(bg.next)
      end
    end

    def draw_rect(x:, y:, width:, height:, char: '█', color: :white)
      (x..(x + width - 1)).each do |x_pos|
        (y..(y + height - 1)).each do |y_pos|
          self[x_pos, y_pos] = char.fg(color)
        end
      end
    end

    # TODO: Add `[](x,y)`

    def []=(x, y, value)
      @canvas[at(x, y)] = value
    end

    def clear
      @canvas = @blank_canvas
    end

    def bg=(bg)
      @bg = bg

      create_blank_canvas
      # NOTE: Should I run `clear` too?
    end

    private

    def [](x, y)
      @canvas[at(x, y)]
    end

    def at(x, y)
      y * @width + x
    end

    def create_blank_canvas
      @blank_canvas = (0...(@width * @height)).map { @bg }
    end
  end
end
