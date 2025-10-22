# frozen_string_literal: true

module RichEngine
  # Animation is a simple sprite sequence player.
  #
  # Usage:
  #   frames = [
  #     "A",
  #     "B"
  #   ]
  #   anim = RichEngine::Animation.new(frames: frames, fps: 8, loop: true)
  #
  #   # Inside your Game loop:
  #   anim.update(elapsed_time)
  #   anim.draw(@canvas, x: 10, y: 2, fg: :yellow)
  #
  class Animation
    attr_reader :frames, :frame_index, :fps
    attr_accessor :fg

    def initialize(frames:, fps: 12, loop: true, fg: :white)
      @frames = frames
      @fps = fps
      @loop = loop
      @fg = fg
      @frame_index = 0
      @playing = true
      @stepper = RichEngine::Timer.every(seconds: frame_interval)
    end

    def fps=(value)
      @fps = value
      @stepper.interval = frame_interval
    end

    def loop? = @loop
    def playing? = @playing

    def stop!
      @playing = false
      reset!
    end

    def pause!
      @playing = false
    end

    def play!
      @playing = true
    end

    def reset!
      @frame_index = 0
      @stepper.interval = frame_interval
    end

    def current_frame
      @frames[@frame_index]
    end

    def update(elapsed_time)
      return unless @playing
      return if @frames.size <= 1

      @stepper.update(elapsed_time)
      @stepper.when_ready { advance_frame }
    end

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
