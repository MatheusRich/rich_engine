# frozen_string_literal: true

module RichEngine
  class Matrix
    # TODO: implement Enumerable

    attr_accessor :vec

    def initialize(width: 1, height: 1, fill_with: nil)
      @vec = Array.new(width) { Array.new(height) { fill_with } }
    end

    def [](x, y)
      @vec[x][y]
    end

    def []=(x, y, value)
      @vec[x][y] = value
    end

    def any?(&block)
      @vec.any? { |row| row.any?(&block) }
    end

    def each
      @vec.each do |row|
        row.each do |tile|
          yield(tile)
        end
      end
    end

    def map(&block)
      @vec.map do |row|
        row.map { |value| block.call(value) }
      end
    end

    def zip(other)
      new_matrix = Matrix.new
      new_matrix.vec = @vec.map.with_index do |row, i|
        row.map.with_index { |value, j| [value, other[i, j]] }
      end

      new_matrix
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
