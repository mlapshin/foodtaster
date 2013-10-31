require 'open3'

module Foodtaster
  class ServerProcess
    def initialize(drb_port)
      Foodtaster.logger.debug "Starting Foodtaster specs run"

      vagrant_binary = Foodtaster.config.vagrant_binary

      _, @pipe_out, thread = Open3.popen2("#{vagrant_binary} foodtaster-server #{drb_port}",
                                          pgroup: true, err: [:child, :out])

      @pid = thread.pid
      @pgid = Process.getpgid(@pid)

      Foodtaster.logger.debug "Started foodtaster-server on port #{drb_port} with PID #{@pid}"
    end

    def output
      @pipe_out.read
    end

    def alive?
      Process.kill(0, @pid) == 1 rescue false
    end

    def terminate
      if alive?
        @pipe_out.close

        if @pgid > 0
          Process.kill("TERM", -@pgid)
          Process.waitpid(-@pgid) rescue nil
          Foodtaster.logger.debug "Terminated Foodtaster DRb Server process"
        end
      end
    end
  end
end
