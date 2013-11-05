module Foodtaster
  module RSpec
    module ExampleMethods
      def get_vm(vm_name)
        Foodtaster::Vm.get(vm_name)
      end

      def run_chef_on(vm_name, &block)
        chef_config = ChefConfig.new.tap{ |conf| block.call(conf) }.to_hash
        @previous_chef_config = chef_config

        vm = get_vm(vm_name)
        vm.run_chef(chef_config)
      end

      def rerun_chef_on(vm_name)
        raise RuntimeError, "No previous Chef run was made" unless @previous_chef_config
        vm = get_vm(vm_name)
        vm.run_chef(@previous_chef_config)
      end

      alias :repeat_chef_run :rerun_chef_on

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
