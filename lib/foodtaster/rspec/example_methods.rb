module Foodtaster
  module RSpec
    module ExampleMethods
      def get_vm(vm_name)
        Foodtaster::RSpecRun.current.get_vm(vm_name)
      end

      def run_chef_on(vm_name, &block)
        chef_config = ChefConfig.new.tap{ |conf| block.call(conf) }.to_hash
        vm = get_vm(vm_name)
        vm.run_chef(chef_config)
      end

      private

      class ChefConfig
        attr_accessor :json, :run_list

        def initialize
          @json = {}
          @run_list = []
        end

        def add_recipe(name)
          name = "recipe[#{name}]" unless name =~ /^recipe\[(.+?)\]$/
          run_list << name
        end

        def add_role(name)
          name = "role[#{name}]" unless name =~ /^role\[(.+?)\]$/
          run_list << name
        end

        def to_hash
          { json: json, run_list: run_list }
        end
      end
    end
  end
end
