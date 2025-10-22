# frozen_string_literal: true

require "test_helper"

class AnimationTest < Minitest::Test
  def strip_ansi(str)
    str.gsub(/\e\[[0-9;]*m/, "")
  end

  def test_basic_playback_and_loop
    frames = ["A", "B"]
    anim = RichEngine::Animation.new(frames: frames, fps: 2, loop: true)

    assert_equal "A", anim.current_frame

    # 0.25s: no change yet (fps 2 => 0.5s/frame)
    anim.update(0.25)
    assert_equal "A", anim.current_frame

    # Reaching 0.5s should advance to next frame
    anim.update(0.25)
    assert_equal "B", anim.current_frame

    anim.update(0.5)
    assert_equal "A", anim.current_frame, "should loop back to first frame"
  end

  def test_draw_renders_current_frame
    frames = ["X"]
    anim = RichEngine::Animation.new(frames: frames)

    canvas = RichEngine::Canvas.new(1, 1)
    anim.draw(canvas, x: 0, y: 0)

    cell = canvas[0, 0]
    assert_equal "X", strip_ansi(cell)
  end
end
