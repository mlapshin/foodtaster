module Foodtaster
  module RSpec
    module ExampleMethods
      def get_vm(vm_name)
        Foodtaster::Vm.get(vm_name).tap do |vm|
          vm.prepare unless vm.prepared?
        end
      end

      def run_chef_on(vm_name, &block)
        chef_config = ChefConfig.new
        instance_exec chef_config, &block
        chef_config_as_hash = chef_config.to_hash

        @previous_chef_config = chef_config_as_hash

        vm = get_vm(vm_name)
        vm.run_chef(chef_config_as_hash)
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
