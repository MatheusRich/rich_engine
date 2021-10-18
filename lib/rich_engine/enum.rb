module RichEngine
  class Enum
    attr_reader :name, :options

    def initialize(hash)
      check_argument_size(hash)

      @name = hash.keys.first
      @options = hash.values.first.map.with_index.to_h

      @options.each do |k, v|
        define_singleton_method(k) { Enum::Value.new(options: @options.keys, selected: k) }
      end
    end

    private

    def check_argument_size(args)
      raise ArgumentError, "You must provide exactly 1 key/value pair" if args.size != 1

      args
    end
  end
end
