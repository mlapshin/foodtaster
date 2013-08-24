module Foodtaster
  module RSpec
    module DslMethods
      def require_vm(vm_name)
        Foodtaster::RSpecRun.current.require_vm(vm_name)
      end

      def run_chef_on(vm_name, &block)
        require_vm(vm_name)

        skip_rollback = false

        before(:all) do
          vm = get_vm(vm_name)
          vm.rollback unless skip_rollback

          begin
            run_chef_on(vm_name, &block)
          rescue DRb::DRbUnknownError => e
            raise RuntimeError, "Chef Run failed: #{e.message}"
          end
        end

        let(vm_name) { get_vm(vm_name) }
      end
    end
  end
end
