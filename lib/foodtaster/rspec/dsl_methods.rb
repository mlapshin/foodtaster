module Foodtaster
  module RSpec
    module DslMethods
      def require_vm(vm_name)
        let(vm_name) do
          get_vm(vm_name)
        end

        before(:all) { get_vm(vm_name) }
      end

      def run_chef_on(vm_name, options = {}, &block)
        require_vm(vm_name)
        rollback = options.key?(:rollback) ? options[:rollback] : !Foodtaster.config.skip_rollback

        before(:all) do
          vm = get_vm(vm_name)
          vm.rollback if rollback

          run_chef_on(vm_name, &block)
        end
      end
    end
  end
end
