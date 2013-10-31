require 'open3'

module Foodtaster
  class ServerProcess
    def initialize(drb_port)
      Foodtaster.logger.debug "Starting Foodtaster specs run"

      vagrant_binary = Foodtaster.config.vagrant_binary

      @in, @out, wait_thr = Open3.popen2e(vagrant_binary, "foodtaster-server", drb_port.to_s, pgroup: true)
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
      if alive?
        @in.close
        @out.close
        Process.kill("INT", -@pid)
        Process.wait(-@pid) rescue nil
        Foodtaster.logger.debug "Terminated foodtaster-server process"
      end
    end
  end
end
