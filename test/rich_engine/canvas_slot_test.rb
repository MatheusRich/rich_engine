# frozen_string_literal: true

require "test_helper"

class CanvasSlotTest < Minitest::Test
  def test_slot_index_assignment_translates_coordinates
    canvas = RichEngine::Canvas.new(10, 5)
    slot = canvas.slot(x: 2, y: 1, width: 4, height: 3)

    slot[1, 1] = "X"

    assert_equal "X", canvas[3, 2]
  end

  def test_slot_read_translates_coordinates
    canvas = RichEngine::Canvas.new(10, 5)
    canvas[4, 3] = "Z"

    slot = canvas.slot(x: 2, y: 1, width: 4, height: 3)

    assert_equal "Z", slot[2, 2]
  end

  def test_slot_write_string_translates_coordinates
    canvas = RichEngine::Canvas.new(10, 5)
    slot = canvas.slot(x: 2, y: 1, width: 4, height: 3)

    slot.write_string("A", x: 1, y: 1)

    # write_string defaults to fg: :white and bg: :transparent; strip ANSI to assert content
    ansi_stripped = canvas[3, 2].gsub(/\e\[[0-9;]*m/, "")
    assert_equal "A", ansi_stripped
  end

  def test_slot_clear_uses_own_bg
    canvas = RichEngine::Canvas.new(6, 4, bg: ".")
    slot = canvas.slot(x: 1, y: 1, width: 3, height: 2, bg: "-")

    slot.clear

    # Check the 3x2 area is filled with '-'
    (1..3).each do |x|
      (1..2).each do |y|
        assert_equal "-", canvas[x, y]
      end
    end

    # Outside remains the parent's bg
    assert_equal ".", canvas[0, 0]
    assert_equal ".", canvas[5, 3]
  end

  def test_slot_clear_falls_back_to_parent_bg_when_nil
    canvas = RichEngine::Canvas.new(6, 4, bg: "+")
    slot = canvas.slot(x: 2, y: 1, width: 2, height: 2) # bg defaults to nil

    slot.clear

    (2..3).each do |x|
      (1..2).each do |y|
        assert_equal "+", canvas[x, y]
      end
    end
  end

  def test_write_string_is_clipped_to_slot_width
    canvas = RichEngine::Canvas.new(10, 5)
    # 2x1 slot at (8,1): only two characters should fit
    slot = canvas.slot(x: 8, y: 1, width: 2, height: 1)

    slot.write_string("ABC", x: 0, y: 0)

    a = canvas[8, 1].gsub(/\e\[[0-9;]*m/, "")
    b = canvas[9, 1].gsub(/\e\[[0-9;]*m/, "")
    assert_equal "A", a
    assert_equal "B", b
    # No third cell in the slot; ensure neighbor outside slot didn't change (remains bg " ")
    assert_equal " ", canvas[7, 1]
  end

  def test_draw_rect_is_clipped_to_slot_bounds
    canvas = RichEngine::Canvas.new(12, 6)
    slot = canvas.slot(x: 8, y: 3, width: 2, height: 2)

    # A 3x3 rect starting at (-1,-1) in local slot coords should be clipped to 2x2
    slot.draw_rect(x: -1, y: -1, width: 3, height: 3)

    [[8,3],[9,3],[8,4],[9,4]].each do |x,y|
      # Strip ANSI; expect the filled char "█"
      val = canvas[x,y].gsub(/\e\[[0-9;]*m/, "")
      assert_equal "█", val
    end

    # Outside the slot area shouldn't be affected
    assert_equal " ", canvas[7, 2]
  end

  def test_direct_write_outside_slot_is_ignored
    canvas = RichEngine::Canvas.new(10, 5)
    slot = canvas.slot(x: 2, y: 2, width: 3, height: 2)

    slot[-1, 0] = "X"  # outside to the left
    slot[3, 1] = "Y"   # outside to the right (width = 3 -> max index 2)
    slot[1, 2] = "Z"   # outside on bottom (height = 2 -> max index 1)

    # None of these writes should reflect on the parent canvas
    refute_equal "X", canvas[1, 2]
    refute_equal "Y", canvas[5, 3]
    refute_equal "Z", canvas[3, 4]
  end
end
