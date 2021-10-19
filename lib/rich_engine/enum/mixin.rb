module RichEngine
  class Enum
    module Mixin
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
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
