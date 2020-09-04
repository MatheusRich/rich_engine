# frozen_string_literal: true

require_relative 'canvas'
require_relative 'io'

module RichEngine
  # Example:
  #
  #    class MyGame < RichEngine::Game
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
  class Game
    def initialize(width, height)
      @width = width
      @height = height
      @active = true
      @io = RichEngine::IO.new(width, height)
      @canvas = RichEngine::Canvas.new(width, height)
    end

    def self.play(width = 50, height = 10)
      new(width, height).send(:play)
    end

    def on_create
      raise NotImplementedError
    end

    def on_update(_elapsed_time, _key)
      raise NotImplementedError
    end

    def write_string(...)
      @canvas.write_string(...)
    end

    private

    def play
      on_create

      previous_time = Time.now

      while @active
        current_time = Time.now
        elapsed_time = current_time - previous_time
        previous_time = current_time

        key = process_input
        on_update(elapsed_time, key) || deactivate!
        render
      end
    end

    def deactivate!
      @active = false
    end

    def process_input
      @io.read_async
    end

    def render
      @io.write(@canvas.canvas)
    end
  end
end
