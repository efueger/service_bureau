module ServiceBureau
  # Finds service factories and instantiates services
  class Locator
    # Initializes a new Locator with the mapping of service keys to factories.
    def initialize
      @service_factories = ServiceBureau::Locations.factory_map
    end

    # Finds a factory and instantiates a service
    #
    # @param service_key [Symbol] the service to look up
    # @param args will be passed to the factory's call method.
    #
    # @return An instance of the service
    #
    # @raise [UnknownServiceError] If a factory cannot be found.
    # @raise [UncallableFactoryError] If a factory is found, but does not respond to call
    def self.get_service service_key, *args
      @instance ||= new
      @instance.get_service service_key, *args
    end

    # (see .get_service)
    def get_service service_key, *args
      service_factories.fetch(service_key).call *args

    rescue KeyError
      raise UnknownServiceError.new("Cannot locate factory for '#{service_key}' - please check your configuration")

    rescue NoMethodError => err
      if err.message =~ /undefined method `call'/
        raise UncallableFactoryError.new("The factory registered for '#{service_key}' did not respond to #call")
      else
        raise
      end
    end

    private

    attr_reader :service_factories
  end
end
