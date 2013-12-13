require "service_bureau"

describe ServiceBureau::Locator do
  let(:a_service_obj){ double('some service instance') }
  let(:factory){ ->(arg){ double('other service') } }

  subject(:locator){ ServiceBureau::Locator.new }

  before(:each) do
    ServiceBureau::Locations.configure do |config|
      config.bones_mccoy "Dammit, Jim! I'm a String, not a callable."
      config.some_service ->{ a_service_obj }
      config.other_service factory
    end
  end

  describe '#get_service' do
    it "gets a configured service" do
      found_svc = locator.get_service :some_service
      expect(found_svc).to equal a_service_obj
    end

    it "instantiates a service with args given" do
      expect(factory).to receive(:call).with('foo')
      locator.get_service :other_service, 'foo'
    end

    context 'when no service is registered' do
      it "raises UnknownServiceError" do
        expect{ locator.get_service :no_such_svc }
          .to raise_error(ServiceBureau::UnknownServiceError)
      end
    end

    context 'when the factory registered is not callable' do
      it "raises UncallableFactoryError" do
        expect{ locator.get_service :bones_mccoy }
          .to raise_error(ServiceBureau::UncallableFactoryError)
      end
    end
  end

  describe '.get_service' do
    it "gets a configured service" do
      found_svc = ServiceBureau::Locator.get_service :some_service
      expect(found_svc).to equal a_service_obj
    end

    it "instantiates a service with args given" do
      expect(factory).to receive(:call).with('foo')
      ServiceBureau::Locator.get_service :other_service, 'foo'
    end

    context 'when no service is registered' do
      it "raises UnknownServiceError" do
        expect{ ServiceBureau::Locator.get_service :no_such_svc }
          .to raise_error(ServiceBureau::UnknownServiceError)
      end
    end

    context 'when the factory registered is not callable' do
      it "raises UncallableFactoryError" do
        expect{ ServiceBureau::Locator.get_service :bones_mccoy }
          .to raise_error(ServiceBureau::UncallableFactoryError)
      end
    end
  end
end

describe ServiceBureau::Locations do
  describe ".configure" do
    it "should not register a service with no arguments" do
      expect{ ServiceBureau::Locations.configure { |cfg| cfg.no_args } }.to raise_error(NoMethodError)
    end

    it "should not register a service with multiple arguments" do
      expect{ ServiceBureau::Locations.configure { |cfg| cfg.two_args :foo, :bar } }.to raise_error(NoMethodError)
    end

    it "should not register a service with a block argument" do
      expect{ ServiceBureau::Locations.configure { |cfg| cfg.block_args(:foo){ :bar } } }.to raise_error(NoMethodError)
    end
  end

  describe '.clear' do
    before(:each) do
      ServiceBureau::Locations.configure do |config|
        config.a_service :foo
      end
    end

    it "should clear the factory_map" do
      ServiceBureau::Locations.clear
      expect(ServiceBureau::Locations.factory_map).to eq({})
    end
  end

  describe '.factory_map' do
    before(:each) do
      ServiceBureau::Locations.clear
      ServiceBureau::Locations.configure do |config|
        config.a_service :foo
        config.another_service :bar
      end
    end

    it "should return the hash of factories" do
      expect(ServiceBureau::Locations.factory_map).to eq(a_service: :foo, another_service: :bar)
    end
  end
end

describe ServiceBureau::Services do
  let(:a_service){ double('some service') }
  let(:factory){ ->(arg){ a_service } }
  let(:locator){ ServiceBureau::Locator.new }

  subject(:test_obj){ (Class.new{include ServiceBureau::Services}).new }

  before(:each) do
    ServiceBureau::Locations.clear
    ServiceBureau::Locations.configure do |config|
      config.my_service factory
    end
  end

  it "provides access to a service instance" do
    expect(test_obj.my_service(42)).to equal(a_service)
  end

  it "provides a way to inject a different service object (e.g. for tests)" do
    injected = double('injected')
    test_obj.my_service = injected
    expect(test_obj.my_service(42)).to equal(injected)
  end
end
