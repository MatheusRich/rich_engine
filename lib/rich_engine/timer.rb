# frozen_string_literal: true

module RichEngine
  class Timer
    def self.every(seconds: 1, &block)
      Every.new(seconds)
    end

    def initialize
      @timer = 0
    end

    def update(dt)
      @timer += dt
    end

    def get
      @timer
    end

    def reset!
      @timer = 0
    end
  end
end
