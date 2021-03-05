# frozen_string_literal: true

module RichEngine
  class Vec2
    def initialize(width:, height:, fill_with:)
      @vec = Array.new(width) { Array.new(height) { fill_with } }
    end

    def [](x, y)
      @vec[x][y]
    end

    def []=(x, y, value)
      @vec[x][y] = value
    end

    def each
      @vec.each do |row|
        row.each do |tile|
          yield(tile)
        end
      end
    end

    def each_with_indexes
      @vec.each_with_index do |row, i|
        row.each_with_index do |tile, j|
          yield(tile, i, j)
        end
      end
    end

    def fill(x:, y:, with:)
      xs = Iterable(x)
      ys = Iterable(y)

      xs.each do |x|
        ys.each do |y|
          @vec[x][y] = with
        end
      end
    end

    private

    def Iterable(value)
      value.respond_to?(:each) ? value : [value]
    end
  end
end
