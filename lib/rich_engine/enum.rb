module RichEngine
  class Enum
    attr_reader :name, :values

    def initialize(hash)
      check_argument_size(hash)

      @name = hash.keys.first
      @values = hash.values.first.map.with_index.to_h

      @values.each do |k, v|
        define_singleton_method(k) { v }
      end
    end

    private

    def check_argument_size(args)
      raise ArgumentError, "You must provide exactly 1 key/value pair" if args.size != 1

      args
    end
  end
end
