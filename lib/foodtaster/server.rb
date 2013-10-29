module Foodtaster
  class Server
    class << self
      def start(drb_port)
        Foodtaster.logger.debug "Starting Foodtaster specs run"

        vagrant_binary = Foodtaster.config.vagrant_binary
        vagrant_server_cmd = "#{vagrant_binary} foodtaster-server #{drb_port} &> /tmp/vagrant-foodtaster-server-output.txt"

        server_pid = Process.spawn(vagrant_server_cmd, pgroup: true)
        Foodtaster.logger.debug "Started foodtaster-server on port #{drb_port} with PID #{@server_pid}"
        server_pid
      end

      def terminate(server_pid)
        return unless server_pid
        pgid = Process.getpgid(server_pid) rescue 0

        if pgid > 0
          Process.kill("INT", -pgid)
          Process.wait(-pgid)
          Foodtaster.logger.debug "Terminated foodtaster-server process"
        end
      end
    end
  end
end
