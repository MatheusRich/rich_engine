# frozen_string_literal: true

require "test_helper"

class ChanceTest < Minitest::Test
  def test_chance_of
    assert_equal false, RichEngine::Chance.of(50, rand_gen: rand_mock(returns: 0.6))
    assert_equal true, RichEngine::Chance.of(50, rand_gen: rand_mock(returns: 0.4))
    assert_equal false, RichEngine::Chance.of(50, rand_gen: rand_mock(returns: 0.5))
    assert_equal true, RichEngine::Chance.of(100)
    assert_equal false, RichEngine::Chance.of(0)
  end

  private

  def rand_mock(returns:)
    -> { returns }
  end
end
