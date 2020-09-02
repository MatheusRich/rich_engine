# frozen_string_literal: true

require 'test_helper'

class TimerTest < Minitest::Test
  def test_should_get_time
    timer = RichEngine::Timer.new
    assert_equal 0, timer.get

    timer.update(1)
    assert_equal 1, timer.get
  end

  def test_should_update_time
    timer = RichEngine::Timer.new

    assert_equal 0, timer.update(0)
    assert_in_delta(1.5, timer.update(1.5))
    assert_in_delta(2.5, timer.update(1))
  end

  def test_should_reset_time
    timer = RichEngine::Timer.new
    timer.update(1)
    timer.reset!

    assert_equal 0, timer.get
  end
end
