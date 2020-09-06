# frozen_string_literal: true

module RichEngine
  class Canvas
    attr_reader :canvas

    def initialize(width, height, canvas_bg: ' ')
      @width = width
      @height = height
      @canvas_bg = canvas_bg
      @canvas = blank_canvas
    end

    def dimentions
      [@width, @height]
    end

    def write_string(str, x:, y:)
      str.each_char.with_index do |char, i|
        @canvas[at(x + i, y)] = char
      end
    end

    def []=(x, y, value)
      @canvas[at(x, y)] = value
    end

    def clear
      @canvas = blank_canvas
    end

    private

    def [](x, y)
      @canvas[at(x, y)]
    end

    def at(x, y)
      y * @width + x
    end

    def blank_canvas
      (0...(@width * @height)).map { @canvas_bg }
    end
  end
end
