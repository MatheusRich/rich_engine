module RichEngine
  class Enum
    class Value
      def initialize(options:, selected:)
        @options = options
        @selected = selected

        check_selected_is_a_valid_option
        define_query_methods
      end

      private

      def check_selected_is_a_valid_option
        msg = "Unknown enum value `#{@selected}`. Options are `#{@options}`"

        raise(ArgumentError, msg) unless @options.include? @selected
      end

      def define_query_methods
        @options.each do |enum_option|
          define_singleton_method("#{enum_option}?") { enum_option == @selected }
        end
      end
    end
  end
end
