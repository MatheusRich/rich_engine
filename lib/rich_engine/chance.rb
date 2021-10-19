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
  end
end
