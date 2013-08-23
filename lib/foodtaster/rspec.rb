module Foodtaster
  module RSpec
    autoload :ExampleMethods, "foodtaster/rspec/example_methods"
    autoload :DslMethods, "foodtaster/rspec/dsl_methods"
  end
end

require 'foodtaster/rspec/config'

# require all matchers
Dir[File.dirname(__FILE__) + "/rspec/matchers/*.rb"].each do |f|
  require f
end

RSpec::Matchers.send(:include, Foodtaster::RSpec::Matchers::MatcherMethods)
