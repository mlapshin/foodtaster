module Foodtaster
  class ServerProcess
    def initialize(drb_port)
      Foodtaster.logger.debug "Starting Foodtaster specs run"

      vagrant_binary = Foodtaster.config.vagrant_binary
      vagrant_server_cmd = "#{vagrant_binary} foodtaster-server #{drb_port} &> /tmp/vagrant-foodtaster-server-output.txt"

      @pid = Process.spawn(vagrant_server_cmd, pgroup: true)
      Foodtaster.logger.debug "Started foodtaster-server on port #{drb_port} with PID #{@pid}"
    end

    def terminate
      return unless @pid
      pgid = Process.getpgid(@pid) rescue 0

      if pgid > 0
        Process.kill("INT", -pgid)
        Process.wait(-pgid)
        Foodtaster.logger.debug "Terminated foodtaster-server process"
      end
    end
  end
end
