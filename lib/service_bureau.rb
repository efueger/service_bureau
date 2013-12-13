require "service_bureau/version"
require "service_bureau/locations"
require "service_bureau/locator"
require "service_bureau/services"

# Provides easy access to service dependencies, as well
# as a way to inject them as dependencies.
module ServiceBureau
  # Raised when a requested service is not configured
  class UnknownServiceError < StandardError;end
  # Raised when a requested service cannot be instantiated.
  class UncallableFactoryError < StandardError;end
end
