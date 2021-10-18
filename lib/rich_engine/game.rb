# frozen_string_literal: true

require_relative "canvas"
require_relative "io"

module RichEngine
  # Example:
  #
  #   class MyGame < RichEngine::Game
  #     def on_create
  #       @title = "My Awesome Game"
  #     end
  #
  #     def on_update(elapsed_time, key)
  #       raise MyGame::Exit if key == :q
  #
  #       @canvas.write_string(@title, x: 1, y: 1)
  #       @io.write(@canvas.canvas)
  #
  #       true
  #     end
  #   end
  #
  #   MyGame.play
  #
  class Game
    class Exit < StandardError; end

    def initialize(width, height)
      @width = width
      @height = height
      @io = RichEngine::IO.new(width, height)
      @canvas = RichEngine::Canvas.new(width, height)
    end

    def self.play(width = 50, height = 10)
      new(width, height).play
    end

    def play
      Terminal.clear
      Terminal.hide_cursor
      Terminal.disable_echo

      on_create

      previous_time = Time.now

      loop do
        current_time = Time.now
        elapsed_time = current_time - previous_time
        previous_time = current_time

        key = read_input
        should_keep_playing = check_exit { on_update(elapsed_time, key) }

        break unless should_keep_playing
      end

      on_destroy
    ensure
      Terminal.display_cursor
      Terminal.enable_echo
    end

    def on_create
    end

    def on_update(_elapsed_time, _key)
    end

    def on_destroy
    end

    private

    def read_input
      @io.read_async
    end

    def render
      @io.write(@canvas.canvas)
    end

    def check_exit
      yield
    rescue Exit
      false
    end
  end
end
