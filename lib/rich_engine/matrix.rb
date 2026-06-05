# frozen_string_literal: true

module RichEngine
  # A simple 2D grid utility backed by nested arrays, with convenience methods
  # for indexing, iterating, mapping, zipping, and filling regions.
  #
  # @example
  #   grid = RichEngine::Matrix.new(width: 10, height: 5, fill_with: 0)
  #   grid[2, 3] = 1
  #   grid.fill(x: 0..2, y: 0..1, with: 9)
  class Matrix
    # TODO: implement Enumerable

    # @return [Array<Array>] the backing nested array of rows
    attr_accessor :vec

    # Builds a matrix of the given dimensions, filling every cell with
    # +fill_with+.
    #
    # @param width [Integer] the number of columns
    # @param height [Integer] the number of rows
    # @param fill_with [Object] the initial value for every cell
    def initialize(width: 1, height: 1, fill_with: nil)
      @vec = Array.new(width) { Array.new(height) { fill_with } }
    end

    # Reads the value at the given coordinates.
    #
    # @param x [Integer] the column index
    # @param y [Integer] the row index
    # @return [Object] the value at +(x, y)+
    def [](x, y)
      @vec[x][y]
    end

    # Writes a value at the given coordinates.
    #
    # @param x [Integer] the column index
    # @param y [Integer] the row index
    # @param value [Object] the value to store
    # @return [Object] the stored value
    def []=(x, y, value)
      @vec[x][y] = value
    end

    # Whether any cell matches the given block.
    #
    # @yield [cell] each cell in the matrix
    # @return [Boolean] true if the block returns truthy for any cell
    def any?(&block)
      @vec.any? { |row| row.any?(&block) }
    end

    # Iterates over every cell in row-major order.
    #
    # @yield [tile] each cell value
    # @return [void]
    def each
      @vec.each do |row|
        row.each do |tile|
          yield(tile)
        end
      end
    end

    # Maps every cell through the block, returning a nested array of results.
    #
    # @yield [value] each cell value
    # @return [Array<Array>] a nested array of mapped values
    def map(&block)
      @vec.map do |row|
        row.map { |value| block.call(value) }
      end
    end

    # Pairs each cell with the cell at the same coordinates in +other+.
    #
    # @param other [Matrix] another matrix of the same dimensions
    # @return [Matrix] a new matrix whose cells are +[self_value, other_value]+
    #   pairs
    def zip(other)
      new_matrix = Matrix.new
      new_matrix.vec = @vec.map.with_index do |row, i|
        row.map.with_index { |value, j| [value, other[i, j]] }
      end

      new_matrix
    end

    # Iterates over every cell along with its column and row indexes.
    #
    # @yield [tile, i, j] each cell value with its column index +i+ and row
    #   index +j+
    # @return [void]
    def each_with_indexes
      @vec.each_with_index do |row, i|
        row.each_with_index do |tile, j|
          yield(tile, i, j)
        end
      end
    end

    # Fills a cell or region with a value. +x+ and +y+ may each be a single
    # index or any object responding to +each+ (e.g. a Range), so regions can
    # be filled in one call.
    #
    # @param x [Integer, #each] the column index or range of columns
    # @param y [Integer, #each] the row index or range of rows
    # @param with [Object] the value to write
    # @return [void]
    # @example Fill a region
    #   grid.fill(x: 0..2, y: 0..1, with: 9)
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
