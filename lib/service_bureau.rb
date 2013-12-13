require "service_bureau/version"
require "service_bureau/locations"
require "service_bureau/locator"
require "service_bureau/services"

module ServiceBureau
  class UnknownServiceError < StandardError;end
  class UncallableFactoryError < StandardError;end
end
