require 'drb'

module Foodtaster
  class Client
    def initialize(drb_port)
      # start local service to be able to redirect stdout & stderr
      # to client
      DRb.start_service("druby://localhost:0")
      @v = DRbObject.new_with_uri("druby://localhost:#{drb_port}")

      init
    end

    [:vm_defined?, :prepare_vm, :rollback_vm,
     :run_chef_on_vm, :execute_command_on_vm,
     :shutdown_vm].each do |method_name|
      define_method method_name do |*args|
        begin
          @v.send(method_name, *args)
        rescue DRb::DRbUnknownError => e
          puts '='*30
          puts 'Folowing error was raised on server: '
          puts e.unknown.buf
          puts '='*30
          raise e
        end
      end
    end

    private

    def init
      $stdout.extend DRbUndumped
      $stderr.extend DRbUndumped

      @v.redirect_stdstreams($stdout, $stderr)
    end
  end
end
