# Foodtæster

[![Gem Version](https://badge.fury.io/rb/foodtaster.png)](http://badge.fury.io/rb/foodtaster)

Foodtaster is a library for testing your Chef code with RSpec. Specs
are actually executed on VirtualBox machine(s) managed by
[Vagrant](http://www.vagrantup.com/).

Foodtaster uses VM snapshots to bring something like DB transactions
into your cookbook specs. Before each Chef Run VM is rolled-back into
initial 'clean' state which removes any modifications made by
previously executed specs. It allows you to independently test different
cookbooks on a single VM.

You aren't limited by just one VM for your specs, you may
run as many as you need. PostgreSQL replication, load balancing and
even entire application environments becomes testable (of course, if
you have enought amount of RAM for all your VMs).

Check out
[foodtaster-example repository](http://github.com/mlapshin/foodtaster-example)
to see Foodtaster in action.

Foodtaster is on early development stage, so feedback is very
appreciated.

## Documentation

To get more information about FT, read
[Wiki](https://github.com/mlapshin/foodtaster/wiki) or refer to
[RDoc](http://rdoc.info/github/mlapshin/foodtaster/master/frames).

If you have any questions or got in trouble, feel free to ask
community in
[Foodtaster Google Group](https://groups.google.com/forum/?#!forum/foodtaster).

## Quick Example

```ruby
require 'spec_helper'

describe "nginx::default" do
  run_chef_on :vm0 do |c|
    c.json = {}
    c.add_recipe 'nginx'
  end

  it "should install nginx as a daemon" do
    vm0.should have_package 'nginx'
    vm0.should have_user('www-data').in_group('www-data')
    vm0.should have_running_process('nginx')
    vm0.should listen_port(80)

    vm0.should have_file("/etc/nginx/nginx.conf")
      .with_content(/gzip on/)
      .with_mode(0644)
  end

  it "should have valid nginx config" do
    result = vm0.execute("nginx -t")

    result.should be_successful
    result.stdout.should include("/etc/nginx/nginx.conf syntax is ok")
  end
end
```

## Installation

First, install [VirtualBox](http://www.virtualbox.org/) and
[Vagrant](http://docs.vagrantup.com/v2/installation/index.html). Then
install
[vagrant-foodtaster-server](http://github.com/mlapshin/vagrant-foodtaster-server)
plugin:

    vagrant plugin install vagrant-foodtaster-server

## Usage

In your Chef or Cookbook repository, create a basic Gemfile:

    source 'https://rubygems.org/'

    gem 'foodtaster'

Create a Vagrantfile describing VMs you need for specs. [Read
Wiki](https://github.com/mlapshin/foodtaster/wiki/Vagrantfile-Requirements)
for detailed explanation and examples.

Create `spec` folder with basic `spec_helper.rb` file:

```ruby
require 'foodtaster'
```

You are now ready to write cookbook specs. Run them as usual with command:

    bundle exec rspec spec

## Roadmap

- foodtaster-example-single-cookbook repo
- tests/specs
- documentation
- comments in code
- inline sahara plugin into vagrant-foodtaster-server
- Capistrno support or just an example
- Puppet support
- LXC support

## Contributing

If you found a bug or you wish to implement something from Roadmap,
use this workflow:

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Foodtaster is distributed under [MIT
License](http://raw.github.com/mlapshin/foodtaster/master/LICENSE).
