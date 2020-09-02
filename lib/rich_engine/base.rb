# frozen_string_literal: true

module RichEngine
  # Example:
  #
  #    class MyGame < RichEngine::Base
  #      def on_create
  #        @timer = Timer.new
  #      end
  #
  #      def on_update(elapsed_time)
  #        @timer.update(elapsed_time)
  #      end
  #    end
  #
  #    MyGame.play
  #
  class Base
    def initialize(width, height)
      @width = width
      @height = height
      @active = true
    end

    def self.play(width = 80, height = 30)
      new(width, height).play
    end

    def on_create
      raise NotImplementedError
    end

    def on_update(_elapsed_time)
      raise NotImplementedError
    end

    def play
      on_create

      t1 = Time.now

      while active
        t2 = Time.now
        elapsed_time = t2 - t1
        t1 = t2

        handle_keyboard
        on_update(elapsed_time) || deactivate!
        render
      end
    end

    private

    attr_reader :active

    def deactivate!
      @active = false
    end

    def handle_keyboard
      sleep 0.1
    end

    def render
      puts 'rendering...'
    end
  end
end
