# frozen_string_literal: true

module RichEngine
  module Chance
    def self.of(value, rand_gen: method(:rand))
      rand_gen.call < (value / 100.0)
    end
  end
end
