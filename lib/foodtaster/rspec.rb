module Foodtaster
  module RSpec
    autoload :ExampleMethods, "foodtaster/rspec/example_methods"
    autoload :DslMethods, "foodtaster/rspec/dsl_methods"

    def self.configure
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
    end
  end
end

# require all matchers
Dir[File.dirname(__FILE__) + "/rspec/matchers/*.rb"].each do |f|
  require f
end

RSpec::Matchers.send(:include, Foodtaster::RSpec::Matchers::MatcherMethods)
