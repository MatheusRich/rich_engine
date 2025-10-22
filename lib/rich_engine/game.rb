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
  #       quit! if key == :q
  #
  #       @canvas.write_string(@title, x: 1, y: 1)
  #     end
  #   end
  #
  #   MyGame.play
  #
  class Game
    class Exit < StandardError; end

    def initialize(width, height, target_fps: 60)
      @width = width
      @height = height
      @target_fps = target_fps
      @frame_budget = @target_fps ? 1.0 / @target_fps : nil
      @config = {screen_width: @width, screen_height: @height}
      @io = RichEngine::IO.new(width, height)
      @canvas = RichEngine::Canvas.new(width, height)
    end

    def self.play(width: 50, height: 10, target_fps: 60)
      new(width, height, target_fps: target_fps).play
    end

    def play
      prepare_screen
      on_create

      previous_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      loop do
        current_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        elapsed_time = current_time - previous_time
        previous_time = current_time

        check_game_exit do
          game_loop(elapsed_time)
        end
      end

      on_destroy
    ensure
      restore_screen
    end

    def on_create
    end

    def on_update(_elapsed_time, _key)
    end

    def on_destroy
    end

    def quit!
      raise Exit
    end

    def game_loop(elapsed_time)
      key = read_input
      on_update(elapsed_time, key)
      render
      sleep_if_needed(elapsed_time)
    end

    private

    def prepare_screen
      Terminal.clear
      Terminal.hide_cursor
      Terminal.disable_echo
    end

    def restore_screen
      Terminal.display_cursor
      Terminal.enable_echo
    end

    def read_input
      @io.read_async
    end

    def render(use_caching: true)
      @io.write(@canvas.canvas, use_caching: use_caching)
    end

    def sleep_if_needed(elapsed_time)
      return if @frame_budget.nil?

      sleep_time = @frame_budget - elapsed_time
      sleep(sleep_time) if sleep_time > 0
    end

    def check_game_exit
      yield
    rescue Exit
      raise StopIteration
    end
  end
end
