module ServiceBureau
  module Services
    def self.included(base)
      ServiceBureau::Locations.factory_map.keys.each do |service|
        # Provide a method to inject the service obj
        define_method "#{service}=" do |service_obj|
          __set_service__ service, service_obj
        end

        # Provide a handle to the service instance
        define_method service do |*args|
          __get_service__ service, *args
        end
      end
    end

    private

    def __set_service__(key, service_obj)
      instance_variable_set :"@__#{key}__", service_obj
    end

    def __get_service__(key, *args)
      memoized = instance_variable_get :"@__#{key}__"
      return memoized || begin
        __set_service__ key, ServiceBureau::Locator.new.get_service(key, *args)
      end
    end
  end
end
