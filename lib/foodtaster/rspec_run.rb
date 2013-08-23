require 'set'

module Foodtaster
  class RSpecRun
    def initialize
      @required_vm_names = Set.new
      @client = nil
      @server_pid = nil
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
      at_exit { self.stop }

      Foodtaster.logger.debug "Starting Foodtaster specs run"
      start_server_and_connect_client
      prepare_required_vms
    end

    def stop
      puts "" # newline after rspec output
      terminate_server
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

    def prepare_required_vms
      self.required_vm_names.each { |vm_name| get_vm(vm_name).prepare }
    end

    def start_server_and_connect_client(drb_port = Foodtaster.config.drb_port)
      vagrant_binary = Foodtaster.config.vagrant_binary
      vagrant_server_cmd = "#{vagrant_binary} foodtaster-server #{drb_port.to_s} &> /tmp/vagrant-foodtaster-server-output.txt"

      @server_pid = Process.spawn(vagrant_server_cmd, pgroup: true)
      Foodtaster.logger.debug "Started foodtaster-server on port #{drb_port} with PID #{@server_pid}"

      connect_client(drb_port)
    end

    def connect_client(drb_port)
      retry_count = 0
      begin
        sleep 0.2
        @client = Foodtaster::Client.new(drb_port)
      rescue DRb::DRbConnError => e
        Foodtaster.logger.debug "DRb connection failed: #{e.message}"
        retry_count += 1
        retry if retry_count < 10
      end

      if @client.nil?
        server_output = File.read("/tmp/vagrant-foodtaster-server-output.txt")

        Foodtaster.logger.fatal "Cannot start or connect to Foodtaster DRb server."
        Foodtaster.logger.fatal "Server output:\n#{server_output}\n"

        exit 1
      else
        Foodtaster.logger.debug "DRb connection established"
      end
    end

    def terminate_server
      pgid = Process.getpgid(@server_pid) rescue 0

      if pgid > 0
        Process.kill("INT", -pgid)
        Process.wait(-pgid)
        Foodtaster.logger.debug "Terminated foodtaster-server process"
      end
    end
  end
end
