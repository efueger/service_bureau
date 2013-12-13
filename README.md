# ServiceBureau

ServiceBureau provides an easy way to use extracted service objects, as described
by Bryan Helmkamp, in this great article on dealing with fat models: http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/

## Installation

Add this line to your application's Gemfile:

    gem 'service_bureau'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install service_bureau

## Configuration

The ServiceBureau is configured with names of services and factories that
will provide an instance of the service. For services that are classes instead of
instances, you can provide a lambda that returns the class.

A factory can be any object that responds to `#call` - a Proc, lambda, method obj, etc.

If your service requires arguments to initialize it, make sure the proc accepts them.

```ruby
  ServiceBureau::Locations.configure do |config|
    config.my_service ->{ MyService.instance }
    config.another_service AnotherService.public_method(:new)
    config.a_svc_that_needs_args ->(arg1, arg2){ OtherService.new(arg1).setup(arg2) }
    config.static_service ->{ ServiceClass }
  end
```

## Usage

In your client classes, you can use this a couple of ways:

### As a mixin:

You get a handle to the service:

```ruby
class MyClass
  include ServiceBureau::Services

  def my_method
    result = my_service.do_something
  end

  # if initialization is needed, just pass in the args.
  def my_method
    result = my_service(42).do_something
  end
end
```

And you get an injector to keep your tests fast and decoupled:
```ruby
describe MyClass
  let(:stubbed_service){ double('fake service', do_something: "a result") }

  subject(:my_obj){ MyClass.new }

  before do
    my_class.my_service = stubbed_service
  end

  # stubbed
  it "does something" do
    expect(my_class.my_method).to eq("a result")
  end

  # mocked
  it "does something" do
    expect(stubbed_service).to receive(:do_something).and_return("a result")
    my_class.my_method
  end
end
```

### As a regular class method lookup
```ruby
class MyClass
  def my_method
    service = ServiceBureau::Locator.get_service(:my_service, 'any', 'arguments')
    result = service.do_something
  end
end
```

The handle to the instance will memoize it, and only instantiate it the first time it is called.
If you need a new instance, you can use the injector to clear out the old one,
or you can use the class method on Locator to get a new instance (and you can use the injector
if you want to replace the old one.)

```ruby
class MyClass
  include ServiceBureau::Services

  def use_service_with_foo
    result = my_service(:foo).do_something
  end

  def use_service_with_bar
    service = ServiceBureau::Locator.get_service(:my_service, :bar)
    result = service.do_something
  end

  def set_service_to_baz
    new_service_obj = ServiceBureau::Locator.get_service(:my_service, :baz)
    my_service = new_service_obj
  end
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
