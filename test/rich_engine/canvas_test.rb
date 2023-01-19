# frozen_string_literal: true

require "test_helper"

class CanvasTest < Minitest::Test
  def test_canvas_clear
    canvas = RichEngine::Canvas.new(10, 10)
    canvas.write_string("Hello", x: 0, y: 0)

    canvas.clear

    assert_equal Array.new(100, " "), canvas.canvas
  end
end
