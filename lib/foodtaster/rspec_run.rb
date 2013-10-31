require 'set'

module Foodtaster
  class RSpecRun
    def initialize
      @required_vm_names = Set.new
      @client = nil
      @server_process = nil
      @stopped = false
    end

    def require_vm(vm_name)
      @required_vm_names.add(vm_name.to_sym)
    end

    def required_vm_names
      @required_vm_names
    end

    def get_vm(vm_name)
      Foodtaster::Vm.new(vm_name, @client)
    end

    def start
      setup_signal_handlers
      start_server_and_connect_client
      prepare_required_vms
    end

    def stop
      return if @stopped

      puts "" # newline after rspec output
      shutdown_required_vms if Foodtaster.config.shutdown_vms
      terminate_server
      @stopped = true
    end

    def client
      @client
    end

    class << self
      @instance = nil

      def current
        @instance ||= self.new
      end
    end

    private

    def setup_signal_handlers
      terminator = proc {
        self.stop
      }

      at_exit(&terminator)
      trap("INT", &terminator)
      trap("TERM", &terminator)
    end

    def prepare_required_vms
      self.required_vm_names.each { |vm_name| get_vm(vm_name).prepare }
    end

    def shutdown_required_vms
      self.required_vm_names.each { |vm_name| get_vm(vm_name).shutdown }
    end

    def start_server_and_connect_client
      drb_port = Foodtaster.config.drb_port

      start_server(drb_port) if Foodtaster.config.start_server
      connect_client(drb_port)
    end

    def start_server(drb_port)
      @server_process = Foodtaster::ServerProcess.new(drb_port)
    end

    def terminate_server
      @server_process.terminate
    end

    def connect_client(drb_port)
      @client = Foodtaster::Client.connect(drb_port)
    end
  end
end
