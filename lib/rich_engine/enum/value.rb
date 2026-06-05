module RichEngine
  class Enum
    # A single selected option of an {Enum}. Values are comparable (by their
    # underlying option value) and expose a query method per option, e.g.
    # +#idle?+. Only values from the same enum can be compared or are equal.
    #
    # @example
    #   state = RichEngine::Enum.new(:state, {idle: 0, running: 1})
    #   value = state.running
    #   value.running? #=> true
    #   value.value    #=> 1
    class Value
      include Comparable

      # @return [Enum] the enum this value belongs to
      # @return [Symbol] the selected option
      attr_reader :enum, :selected

      # Builds a value for a selected option and defines a query method per
      # option (e.g. +#idle?+).
      #
      # @param enum [Enum] the enum this value belongs to
      # @param selected [Symbol] the selected option; must be a valid option of
      #   +enum+
      # @raise [ArgumentError] if +selected+ is not an option of +enum+
      def initialize(enum:, selected:)
        @enum = enum
        @selected = selected

        check_selected_is_a_valid_option
        define_query_methods

        freeze
      end

      # The underlying value of the selected option.
      #
      # @return [Object] the value mapped to the selected option
      def value
        @enum[@selected]
      end

      # Compares two values from the same enum by their underlying values.
      #
      # @param other [Value] another value from the same enum
      # @return [Integer] -1, 0, or 1
      # @raise [ArgumentError] if +other+ belongs to a different enum
      def <=>(other)
        raise ArgumentError, "Can't compare values from different enums" if enum != other.enum

        value <=> other.value
      end

      # Two values are equal when they come from the same enum and have the
      # same selected option.
      #
      # @param other [Object] the object to compare against
      # @return [Boolean] whether the values are equal
      def ==(other)
        return @enum == other.enum && selected == other.selected if other.is_a? self.class

        super
      end

      private

      def check_selected_is_a_valid_option
        msg = "Unknown enum value `#{@selected}`. Options are `#{@enum.options.keys}`"

        raise(ArgumentError, msg) unless @enum.options.has_key? @selected
      end

      def define_query_methods
        @enum.options.each do |enum_option, _value|
          define_singleton_method("#{enum_option}?") { enum_option == @selected }
        end
      end
    end
  end
end
