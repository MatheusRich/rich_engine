# frozen_string_literal: true

module RichEngine
  module Chance
    def self.of(value, rand_gen: method(:rand))
      percent = if value > 1
        value / 100.0
      else
        value
      end

      rand_gen.call < percent
    end

    def self.of_one_in(value, rand_gen: method(:rand))
      of(1 / value.to_f, rand_gen: rand_gen)
    end
  end
end
