# frozen_string_literal: true

require "test_helper"

class StringColorsTest < Minitest::Test
  using RichEngine::StringColors

  def test_named_colors_use_fixed_256_color_indices
    assert_equal "\e[38;5;160mx\e[39m", "x".fg(:red)
    assert_equal "\e[48;5;51mx\e[49m", "x".bg(:bright_cyan)
  end

  def test_named_color_methods_match_fg_and_bg
    assert_equal "x".fg(:red), "x".red
    assert_equal "x".bg(:red), "x".on_red
  end

  def test_named_colors_avoid_the_theme_dependent_0_to_15_range
    RichEngine::StringColors::PALETTE.each_value do |index|
      assert index.between?(16, 255), "expected #{index} to be in 16..255"
    end
  end

  def test_fg_accepts_hex_strings
    assert_equal "\e[38;5;196mx\e[39m", "x".fg("#ff0000")
    assert_equal "x".fg("#ff0000"), "x".fg("ff0000")
    assert_equal "x".fg("#ff0000"), "x".fg("#f00")
  end

  def test_fg_accepts_rgb_arrays
    assert_equal "\e[38;5;196mx\e[39m", "x".fg([255, 0, 0])
  end

  def test_fg_accepts_raw_256_color_indices
    assert_equal "\e[38;5;208mx\e[39m", "x".fg(208)
  end

  def test_grays_snap_to_the_grayscale_ramp
    assert_equal "\e[38;5;244mx\e[39m", "x".fg([128, 128, 128])
    assert_equal "\e[38;5;16mx\e[39m", "x".fg("#000")
    assert_equal "\e[38;5;231mx\e[39m", "x".fg("#fff")
  end

  def test_transparent_keeps_its_special_behavior
    assert_equal " ", "x".fg(:transparent)
    assert_equal "\e[49mx\e[49m", "x".bg(:transparent)
  end

  def test_invalid_colors_raise
    assert_raises(KeyError) { "x".fg(:not_a_color) }
    assert_raises(ArgumentError) { "x".fg(1.5) }
  end

  def test_contrast_color_picks_black_or_white_by_wcag_contrast
    assert_equal :black, RichEngine::StringColors.contrast_color(:yellow)
    assert_equal :black, RichEngine::StringColors.contrast_color(:white)
    assert_equal :white, RichEngine::StringColors.contrast_color(:blue)
    assert_equal :white, RichEngine::StringColors.contrast_color(:black)
  end

  def test_contrast_color_accepts_every_color_format
    assert_equal :black, RichEngine::StringColors.contrast_color("#ff8800")
    assert_equal :white, RichEngine::StringColors.contrast_color([0, 0, 215])
    assert_equal :black, RichEngine::StringColors.contrast_color(208)
  end

  def test_contrast_color_rejects_theme_dependent_indices
    assert_raises(ArgumentError) { RichEngine::StringColors.contrast_color(9) }
  end
end
