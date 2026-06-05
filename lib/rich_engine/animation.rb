# frozen_string_literal: true

module RichEngine
  # Plays a sequence of string frames (sprites) at a fixed frames-per-second.
  #
  # @example
  #   frames = [
  #     "A",
  #     "B"
  #   ]
  #   anim = RichEngine::Animation.new(frames: frames, fps: 8, loop: true)
  #
  #   # Inside your Game loop:
  #   anim.update(elapsed_time)
  #   anim.draw(@canvas, x: 10, y: 2, fg: :yellow)
  class Animation
    # @return [Array<String>] the frame sprites, in playback order.
    # @return [Integer] the index of the frame currently shown.
    # @return [Integer, Float] the configured frames per second.
    attr_reader :frames, :frame_index, :fps

    # @return [Symbol, String, Array<Integer>, Integer] default foreground
    #   color used when drawing.
    attr_accessor :fg

    # Builds an animation from a sequence of string frames.
    #
    # @param frames [Array<String>] each string is a frame; can be multi-line.
    #   Spaces are transparent.
    # @param fps [Integer, Float] how many frames per second to advance.
    # @param loop [Boolean] if true, wrap to the first frame after the last;
    #   otherwise stop at the last frame.
    # @param fg [Symbol, String, Array<Integer>, Integer] default foreground
    #   color when drawing.
    # @example
    #   anim = RichEngine::Animation.new(frames: ["A", "B"], fps: 8, loop: true)
    def initialize(frames:, fps: 12, loop: true, fg: :white)
      @frames = frames
      @fps = fps
      @loop = loop
      @fg = fg
      @frame_index = 0
      @playing = true
      @stepper = RichEngine::Timer.every(seconds: frame_interval)
    end

    # Changes playback speed at runtime.
    #
    # @param value [Integer, Float] the new frames per second.
    # @return [Integer, Float] the assigned value.
    def fps=(value)
      @fps = value
      @stepper.interval = frame_interval
    end

    # @return [Boolean] whether the animation wraps after the last frame.
    def loop? = @loop

    # @return [Boolean] whether the animation is currently advancing frames.
    def playing? = @playing

    # Stops playback and rewinds to the first frame.
    #
    # @return [void]
    def stop!
      @playing = false
      reset!
    end

    # Pauses playback on the current frame.
    #
    # @return [void]
    def pause!
      @playing = false
    end

    # Resumes playback.
    #
    # @return [void]
    def play!
      @playing = true
    end

    # Rewinds to the first frame and restarts the frame timer.
    #
    # @return [void]
    def reset!
      @frame_index = 0
      @stepper.interval = frame_interval
    end

    # @return [String] the frame string currently shown.
    def current_frame
      @frames[@frame_index]
    end

    # Advances the internal timer; call once per frame with the elapsed time.
    #
    # @param elapsed_time [Float] seconds since the last frame.
    # @return [void]
    def update(elapsed_time)
      return unless @playing
      return if @frames.size <= 1

      @stepper.update(elapsed_time)
      @stepper.when_ready { advance_frame }
    end

    # Renders the current frame to the canvas.
    #
    # @param canvas [RichEngine::Canvas] the canvas to draw on.
    # @param x [Integer] left column to draw at.
    # @param y [Integer] top row to draw at.
    # @param fg [Symbol, String, Array<Integer>, Integer, nil] foreground
    #   color; falls back to the animation's default when nil.
    # @return [void]
    def draw(canvas, x:, y:, fg: nil)
      canvas.draw_sprite(current_frame, x: x, y: y, fg: fg || @fg)
    end

    private

    def frame_interval
      1.0 / @fps.to_f
    end

    def advance_frame
      if @loop
        @frame_index = (@frame_index + 1) % @frames.size
      elsif @frame_index < @frames.size - 1
        @frame_index += 1
      else
        @playing = false
      end
    end
  end
end
