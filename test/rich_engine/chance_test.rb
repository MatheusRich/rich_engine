# frozen_string_literal: true

require "test_helper"

class ChanceTest < Minitest::Test
  def test_chance_of_with_values_greater_than_1
    assert_equal false, RichEngine::Chance.of(50, rand_gen: rand_mock(returns: 0.6))
    assert_equal true, RichEngine::Chance.of(50, rand_gen: rand_mock(returns: 0.4))
    assert_equal false, RichEngine::Chance.of(50, rand_gen: rand_mock(returns: 0.5))
    assert_equal true, RichEngine::Chance.of(100)
    assert_equal false, RichEngine::Chance.of(0)
  end

  def test_that_with_values_lower_than_1
    assert_equal false, RichEngine::Chance.of(0.5, rand_gen: rand_mock(returns: 0.6))
    assert_equal true, RichEngine::Chance.of(0.5, rand_gen: rand_mock(returns: 0.4))
    assert_equal false, RichEngine::Chance.of(0.5, rand_gen: rand_mock(returns: 0.5))
    assert_equal true, RichEngine::Chance.of(1)
    assert_equal false, RichEngine::Chance.of(0)
  end

  private

  def rand_mock(returns:)
    -> { returns }
  end
end
