module RichEngine
  class Enum
    # Adds enum support to a class. Include it, then declare enums with
    # {ClassMethods#enum} to get a class-level enum accessor and an
    # instance-level reader that resolves the instance variable into an
    # {Enum::Value}.
    #
    # @example
    #   class Player
    #     include RichEngine::Enum::Mixin
    #     enum :state, {idle: 0, running: 1, paused: 2}
    #
    #     def initialize
    #       @state = :idle
    #     end
    #   end
    #
    #   Player.states          #=> RichEngine::Enum
    #   Player.new.state.idle? #=> true
    module Mixin
      # Extends the including class with {ClassMethods}.
      #
      # @param base [Class] the class including this module
      # @return [void]
      def self.included(base)
        base.extend ClassMethods
      end

      # Class-level methods made available by including {Mixin}.
      module ClassMethods
        # Declares an enum on the class. Defines a class method returning the
        # {Enum} (named after +enum_name+) and an instance method (named
        # +name+) that reads the +@name+ instance variable and returns the
        # matching {Enum::Value}.
        #
        # @param name [Symbol] the name of the enum and instance reader; the
        #   value is read from the +@name+ instance variable
        # @param enum_options [Array, Hash] the enum options, as accepted by
        #   {Enum#initialize}
        # @param enum_name [String] the name of the class-level enum accessor;
        #   defaults to the pluralized +name+
        # @return [void]
        def enum(name, enum_options, enum_name: "#{name}s")
          define_singleton_method(enum_name) do
            Enum.new(name, enum_options)
          end

          define_method(name) do
            self.class.public_send(enum_name).public_send(instance_variable_get("@#{name}"))
          end
        end
      end
    end
  end
end
