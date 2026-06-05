# frozen_string_literal: true

require_relative "canvas"
require_relative "io"

module RichEngine
  # The base class for all games. Subclass it, implement the lifecycle hooks,
  # and draw to `@canvas` each frame; the game loop, input, rendering, and
  # frame pacing are handled for you.
  #
  # The lifecycle hooks are the core public API:
  # - {#on_create} runs once at start
  # - {#on_update} runs every frame
  # - {#on_destroy} runs when the game exits
  #
  # @example A minimal game that draws a title and quits on "q"
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
  class Game
    # Raised internally to break out of the game loop. Use {#quit!} instead of
    # raising this directly.
    #
    # @api private
    class Exit < StandardError; end

    # @param width [Integer] the screen width in characters
    # @param height [Integer] the screen height in characters
    # @param target_fps [Integer, nil] target frames per second; pass nil to
    #   run uncapped without frame pacing
    def initialize(width, height, target_fps: 60)
      @width = width
      @height = height
      @target_fps = target_fps
      @frame_budget = @target_fps ? 1.0 / @target_fps : nil
      @config = {screen_width: @width, screen_height: @height}
      @io = RichEngine::IO.new(width, height)
      @canvas = RichEngine::Canvas.new(width, height)
    end

    # Builds a game and runs it. The convenient entry point for starting a
    # game.
    #
    # @param width [Integer] the screen width in characters
    # @param height [Integer] the screen height in characters
    # @param target_fps [Integer, nil] target frames per second; pass nil to
    #   run uncapped without frame pacing
    # @return [void]
    def self.play(width: 50, height: 10, target_fps: 60)
      new(width, height, target_fps: target_fps).play
    end

    # Runs the game: prepares the terminal, calls {#on_create}, then loops
    # calling {#on_update} and rendering every frame until the game exits,
    # finally calling {#on_destroy} and restoring the terminal.
    #
    # @return [void]
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

    # Lifecycle hook called once before the game loop starts. Override it to
    # set up initial state (instance variables, timers, canvas slots, etc.).
    #
    # @return [void]
    def on_create
    end

    # Lifecycle hook called once per frame. Override it to update game state
    # and draw to `@canvas`.
    #
    # @param _elapsed_time [Float] seconds elapsed since the last frame
    # @param _key [Symbol, nil] the last key pressed (e.g. :q, :up, :space,
    #   :esc), or nil if no key was pressed this frame
    # @return [void]
    def on_update(_elapsed_time, _key)
    end

    # Lifecycle hook called once after the game loop ends. Override it to tear
    # down state or print a final message.
    #
    # @return [void]
    def on_destroy
    end

    # Exits the game loop, triggering {#on_destroy} and terminal restore.
    #
    # @return [void]
    # @raise [Exit] always, to unwind out of the loop
    def quit!
      raise Exit
    end

    # Runs a single frame: reads input, calls {#on_update}, renders, and
    # sleeps to honor the target FPS.
    #
    # @param elapsed_time [Float] seconds elapsed since the last frame
    # @return [void]
    # @api private
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
