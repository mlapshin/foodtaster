module Foodtaster
  class RSpecRun
    attr_reader :client

    def initialize
      @client = nil
      @server_process = nil
      @stopped = false
    end

    def start
      setup_signal_handlers
      start_server_and_connect_client

      if (@server_process.nil? || @server_process.alive?) && @client
        # prepare_required_vms
      else
        if @server_process
          Foodtaster.logger.fatal "Failed to start Foodtaster DRb Server:\n\n#{@server_process.output}"
        else
          Foodtaster.logger.fatal "Failed to connect to Foodtaster DRb Server"
        end

        exit 1
      end
    end

    def stop
      return if @stopped

      @stopped = true
      puts "" # newline after rspec output
      Vm.shutdown_running_vms if Foodtaster.config.shutdown_vms
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

    def setup_signal_handlers
      terminator = proc {
        self.stop
        exit 1
      }

      trap("INT", &terminator)
      trap("TERM", &terminator)

      at_exit do
        self.stop
      end
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
      @server_process && @server_process.terminate
    end

    def connect_client(drb_port)
      @client = Foodtaster::Client.connect(drb_port, @server_process)
    end
  end
end
