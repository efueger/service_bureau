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

If you are using Rails, this would go into an initializer.

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

### An instance method lookup
```ruby
class MyClass
  def my_method
    locator = ServiceBureau::Locator.new
    service = locator.get_service(:my_service, 'any', 'arguments')
    result = service.do_something
  end
end
```

### A class method lookup
```ruby
class MyClass
  def my_method
    service = ServiceBureau::Locator.get_service(:my_service, 'any', 'arguments')
    result = service.do_something
  end
end
```

### Notes

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

### Rails Example with services that need services.

Yo dawg! I heard you  like services, so I put a service in your service.
This is helpful if you like keeping you application amde up of small, composable, well-focused pieces of functionality.
```ruby
  # config/initializers/services.rb
  ServiceBureau::Locations.configure do |config|
    config.my_service_a MyServiceA.public_method(:new)
    config.my_service_b MyServiceB.public_method(:new)
    config.my_service_c MyServiceC.public_method(:new)
  end

  # app/services/my_service_a.rb
  class MyServiceA
    def work
      puts "service a"
    end
  end

  # app/services/my_service_b.rb
  class MyServiceB
    include ServiceBureau::Services

    def work
      puts "service b"
      puts my_service_c.work
    end
  end

  # app/services/my_service_c.rb
  class MyServiceC
    def work
      puts "service c"
    end
  end

  # app/models/client.rb
  class Client
    include ServiceBureau::Services

    def do_something
      puts my_service_a.work
      puts my_service_b.work
    end
  end
```

```
> client = Client.new
# => #<Client:0x007deadbeef000>
> client.do_something

# =>
  service a

  service b
  service c
```



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
