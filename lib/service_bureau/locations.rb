module ServiceBureau
  # Stores the factories for all the configured services
  class Locations
    class << self
      # Configures the factories for each service
      #
      # Each service should be configured with an
      # object that responds to 'call'
      #
      # @example
      #   ServiceBureau::Locations.configure do |c|
      #     c.my_service MyService.public_method(:new)
      #     c.other_service ->(arg){ OtherService.new(arg) }
      #   end
      #
      # @return nothing
      # @yield ServiceBureau::Locations
      # @yieldreturn nothing
      def configure(&block)
        yield self
      end

      # @api private
      # Gets the map of service keys to factories.
      #
      # @return [Hash] mapping service keys to factories
      def factory_map
        @factory_map ||= {}
      end

      # Removes all the registered services.
      #
      # @return [Hash] the empty factory_map
      def clear
        factory_map.clear
      end

      # @private
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
