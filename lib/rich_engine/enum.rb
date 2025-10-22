require_relative "enum/value"
require_relative "enum/mixin"

module RichEngine
  class Enum
    attr_reader :name, :options

    def initialize(name, options)
      @name = name
      @options = if options.respond_to? :each_pair
        options
      else
        options.map.with_index.to_h
      end

      @options.each_pair do |option, _value|
        define_singleton_method(option) do
          Enum::Value.new(enum: self, selected: option)
        end
      end

      freeze
    end

    def [](option)
      @options.fetch(option)
    end
  end
end
