require_relative "enum/value"
require_relative "enum/mixin"

module RichEngine
  # An ergonomic, comparable enum with query methods. Options may be given as an
  # array (auto-indexed from 0) or as a hash mapping each option to its value. A
  # reader method is defined for every option that returns an {Enum::Value}.
  #
  # @example Array of options (auto-indexed)
  #   colors = RichEngine::Enum.new(:colors, [:red, :green, :blue])
  #   colors.options #=> {red: 0, green: 1, blue: 2}
  #   colors.red.value #=> 0
  #
  # @example Hash of options with explicit values
  #   state = RichEngine::Enum.new(:state, {idle: 0, running: 1, paused: 2})
  #   state.running > state.idle #=> true
  class Enum
    # @return [Symbol] the name of the enum
    # @return [Hash] the options as a hash mapping each option to its value
    attr_reader :name, :options

    # Builds an enum and defines a reader method for each option.
    #
    # @param name [Symbol] the name of the enum
    # @param options [Array, Hash] option names; an array is auto-indexed from
    #   0, a hash maps each option name to its value
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

    # Looks up the value of an option.
    #
    # @param option [Symbol] the option name
    # @return [Object] the value mapped to that option
    # @raise [KeyError] if the option is unknown
    def [](option)
      @options.fetch(option)
    end
  end
end
