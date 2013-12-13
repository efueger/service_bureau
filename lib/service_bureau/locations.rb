module ServiceBureau
  class Locations
    class << self
      def configure(&block)
        yield self
      end

      def factory_map
        @factory_map ||= {}
      end

      def clear
        factory_map.clear
      end

      def method_missing(method_name, *args, &block)
        if args.size == 1 && !block_given?
          factory_map[method_name] = args.first
        else
          super
        end
      end

    end
  end
end
