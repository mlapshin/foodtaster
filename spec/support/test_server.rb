require 'drb'

class TestServer
  PORT = 4444
  def self.start
    DRb.start_service("druby://localhost:#{PORT}", self.new)
  end
  def self.stop
    DRb.stop_service
  end

  def redirect_stdstreams(stdout, stderr)
  end

  def version
    Foodtaster::VERSION
  end
end


