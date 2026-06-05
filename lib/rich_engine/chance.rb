# frozen_string_literal: true

module RichEngine
  # Random helpers for probability checks.
  module Chance
    # Returns true with the given probability.
    #
    # @param value [Integer, Float] a probability as a fraction (0.2) or as a
    #   percentage (20); values greater than 1 are treated as percentages.
    # @param rand_gen [#call] a generator returning a float in [0, 1).
    # @return [Boolean] whether the chance succeeded.
    # @example
    #   RichEngine::Chance.of(0.2) # 20% chance
    #   RichEngine::Chance.of(20)  # also 20% (percent form)
    def self.of(value, rand_gen: method(:rand))
      percent = if value > 1
        value / 100.0
      else
        value
      end

      rand_gen.call < percent
    end

    # Returns true with a one-in-+value+ probability.
    #
    # @param value [Integer, Float] the denominator of the odds.
    # @param rand_gen [#call] a generator returning a float in [0, 1).
    # @return [Boolean] whether the chance succeeded.
    # @example
    #   RichEngine::Chance.of_one_in(10) # 1 in 10 chance
    def self.of_one_in(value, rand_gen: method(:rand))
      of(1 / value.to_f, rand_gen: rand_gen)
    end
  end
end
