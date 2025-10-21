# frozen_string_literal: true

module RichEngine
  class Cooldown
    def initialize(target_time)
      @target_time = target_time
      @timer = target_time
    end

    def update(dt)
      @timer -= dt
    end

    def get
      @timer
    end

    def reset!
      @timer = @target_time
    end

    def finished?
      @timer <= 0
    end
    alias_method :ready?, :finished?
  end
end
