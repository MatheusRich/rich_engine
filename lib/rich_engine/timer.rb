# frozen_string_literal: true

module RichEngine
  # Accumulates elapsed time; drive it by calling {#update} each frame.
  class Timer
    # Returns a small scheduler that fires a block at a fixed interval.
    #
    # @param seconds [Integer, Float] the interval between firings.
    # @return [RichEngine::Timer::Every] the interval scheduler.
    # @example
    #   spawn = RichEngine::Timer.every(seconds: 0.5)
    #   spawn.update(dt)
    #   spawn.when_ready { spawn_enemy! }
    def self.every(seconds: 1, &block)
      Every.new(seconds)
    end

    def initialize
      @timer = 0
    end

    # Adds the elapsed time to the accumulated total.
    #
    # @param dt [Float] seconds since the last frame.
    # @return [Float] the new accumulated time.
    def update(dt)
      @timer += dt
    end

    # @return [Float] the accumulated time in seconds.
    def get
      @timer
    end

    # Resets the accumulated time back to zero.
    #
    # @return [Integer] zero.
    def reset!
      @timer = 0
    end
  end
end
