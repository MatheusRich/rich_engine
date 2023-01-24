# frozen_string_literal: true

module RichEngine
  class Timer
    class Every
      def initialize(interval)
        @interval = interval
        @ready = false
        @timer = Timer.new
      end

      def update(elapsed_time)
        @timer.update(elapsed_time)

        if @timer.get >= @interval
          @ready = true
        end
      end

      def when_ready(&block)
        if @ready
          block.call
          reset!
        end
      end

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
