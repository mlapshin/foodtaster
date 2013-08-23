RSpec::configure do |config|
  config.include Foodtaster::RSpec::ExampleMethods
  config.extend Foodtaster::RSpec::DslMethods

  config.before(:suite) do
    Foodtaster::RSpecRun.current.start
  end

  config.after(:suite) do
    Foodtaster::RSpecRun.current.stop
  end
end
