require 'open3'

module Foodtaster
  class ServerProcess
    def initialize(drb_port)
      Foodtaster.logger.debug "Starting Foodtaster specs run"

      vagrant_binary = Foodtaster.config.vagrant_binary
      vagrant_server_cmd = "#{vagrant_binary} foodtaster-server #{drb_port}"

      @in, @out, wait_thr = Open3.popen2(vagrant_server_cmd, err: [:child, :out])
      @pid = wait_thr.pid
      Foodtaster.logger.debug "Started foodtaster-server on port #{drb_port} with PID #{@pid}"
    end

    def output
      @out.read
    end

    def alive?
      (not Process.getpgid(@pid).nil?) rescue false
    end

    def terminate
      @in.close
      @out.close
      if alive?
        Process.kill("INT", @pid)
        Process.wait(@pid)
        Foodtaster.logger.debug "Terminated foodtaster-server process"
      end
    end
  end
end
