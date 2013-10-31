# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'foodtaster/version'

Gem::Specification.new do |gem|
  gem.name          = "foodtaster"
  gem.version       = Foodtaster::VERSION
  gem.authors       = ["Mike Lapshin"]
  gem.email         = ["mikhail.a.lapshin@gmail.com"]
  gem.description   = %q{RSpec for Chef cookbooks run on Vagrant}
  gem.summary       = %q{Foodtaster is a library for testing your Chef code with RSpec.}
  gem.homepage      = "http://github.com/mlapshin/foodtaster"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('rspec', '>= 2.10.0')
end
