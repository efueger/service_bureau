module ServiceBureau
  class Locator
    def initialize
      @service_factories = ServiceBureau::Locations.factory_map
    end

    def self.get_service service_key, *args
      @instance ||= new
      @instance.get_service service_key, *args
    end

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
