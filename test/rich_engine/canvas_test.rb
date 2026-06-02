# frozen_string_literal: true

require "test_helper"

class CanvasTest < Minitest::Test
  def test_canvas_clear
    canvas = RichEngine::Canvas.new(10, 10)
    canvas.write_string("Hello", x: 0, y: 0)

    canvas.clear

    assert_equal Array.new(100, " "), canvas.canvas
  end

  def test_write_string_centered_vertically_treats_string_as_one_row_tall
    canvas = RichEngine::Canvas.new(10, 10)

    canvas.write_string("Hello", x: 0, y: :center)

    expected_row = (10 - 1) / 2
    assert_includes canvas[0, expected_row], "H"
  end
end
