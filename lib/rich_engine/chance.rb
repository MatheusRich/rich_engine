# frozen_string_literal: true

module RichEngine
  module Chance
    def self.of(percent, rand_gen: method(:rand))
      rand_gen.call > percent
    end
  end
end
