# frozen_string_literal: true

module RichEngine
  class Cooldown
    def initialize(target_time)
      @timer = 0
      @target_time = target_time
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

    def finished?
      @timer >= @target_time
    end
    alias ready? finished?
  end
end
