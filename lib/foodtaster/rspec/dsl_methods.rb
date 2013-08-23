module Foodtaster
  module RSpec
    module DslMethods
      def run_chef_on(vm_name, &block)
        Foodtaster::RSpecRun.current.require_vm(vm_name)

        skip_rollback = true

        before(:all) do
          vm = get_vm(vm_name)
          vm.rollback unless skip_rollback
          run_chef_on(vm_name, &block)
        end

        let(vm_name) { get_vm(vm_name) }
      end
    end
  end
end
