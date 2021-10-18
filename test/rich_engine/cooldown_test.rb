# frozen_string_literal: true

require "test_helper"

class CooldownTest < Minitest::Test
  def test_should_get_time
    cooldown = RichEngine::Cooldown.new(1)
    assert_equal 0, cooldown.get

    cooldown.update(1)
    assert_equal 1, cooldown.get
  end

  def test_should_update_time
    cooldown = RichEngine::Cooldown.new(1)

    assert_equal 0, cooldown.update(0)
    assert_in_delta(1.5, cooldown.update(1.5))
    assert_in_delta(2.5, cooldown.update(1))
  end

  def test_should_reset_time
    cooldown = RichEngine::Cooldown.new(1)
    cooldown.update(1)
    cooldown.reset!

    assert_equal 0, cooldown.get
  end

  def test_should_tell_when_its_ready
    cooldown = RichEngine::Cooldown.new(1)
    refute cooldown.ready?
    refute cooldown.finished?

    cooldown.update(1)
    assert cooldown.ready?
  end
end
