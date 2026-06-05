# frozen_string_literal: true

module RichEngine
  class Timer
    # A scheduler that fires at a fixed interval, created via {Timer.every}.
    class Every
      # @param interval [Integer, Float] seconds between firings.
      def initialize(interval)
        @interval = interval
        @ready = false
        @timer = Timer.new
      end

      # Accumulates elapsed time and marks the scheduler ready once the
      # interval is reached.
      #
      # @param elapsed_time [Float] seconds since the last frame.
      # @return [void]
      def update(elapsed_time)
        @timer.update(elapsed_time)

        if @timer.get >= @interval
          @ready = true
        end
      end

      # Runs the block and resets the timer when the interval has elapsed.
      #
      # @yield called once each time the interval is reached.
      # @return [void]
      def when_ready(&block)
        if @ready
          block.call
          reset!
        end
      end

      # Changes the firing interval and resets the timer.
      #
      # @param interval [Integer, Float] the new interval in seconds.
      # @return [void]
      def interval=(interval)
        @interval = interval
        reset!
      end

      private

      def reset!
        @timer.reset!
        @ready = false
      end
    end
  end
end
