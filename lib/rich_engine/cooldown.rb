# frozen_string_literal: true

module RichEngine
  # Tracks a fixed delay and reports when it has elapsed.
  #
  # @example
  #   shoot_cd = RichEngine::Cooldown.new(0.25) # seconds
  #   shoot_cd.update(dt)
  #   if shoot_cd.ready?
  #     shoot!
  #     shoot_cd.reset!
  #   end
  class Cooldown
    # @param target_time [Integer, Float] the cooldown duration in seconds.
    def initialize(target_time)
      @target_time = target_time
      @timer = target_time
    end

    # Counts down by the elapsed time.
    #
    # @param dt [Float] seconds since the last frame.
    # @return [Float] the remaining time.
    def update(dt)
      @timer -= dt
    end

    # @return [Float] the remaining time in seconds (negative once finished).
    def get
      @timer
    end

    # Restarts the cooldown at its full duration.
    #
    # @return [Integer, Float] the reset remaining time.
    def reset!
      @timer = @target_time
    end

    # @return [Boolean] whether the cooldown has elapsed.
    def finished?
      @timer <= 0
    end
    alias_method :ready?, :finished?
  end
end
