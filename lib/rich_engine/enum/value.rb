module RichEngine
  class Enum
    class Value
      include Comparable

      attr_reader :enum, :selected

      def initialize(enum:, selected:)
        @enum = enum
        @selected = selected

        check_selected_is_a_valid_option
        define_query_methods

        freeze
      end

      def value
        @enum[@selected]
      end

      def <=>(other)
        raise ArgumentError, "Can't compare values from different enums" if enum != other.enum

        value <=> other.value
      end

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
