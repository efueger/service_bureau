# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'service_bureau/version'

Gem::Specification.new do |spec|
  spec.name          = "service_bureau"
  spec.version       = ServiceBureau::VERSION
  spec.authors       = ["Matt Van Horn"]
  spec.email         = ["mattvanhorn@gmail.com"]
  spec.description   = %q{Something of a cross between a Service Locator and an Abstract Factory to enable easier use of the ServiceObject pattern.}
  spec.summary       = %q{An easy way to provide access to your service classes without creating a lot of coupling}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14"
end
