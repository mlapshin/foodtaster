module Foodtaster
  class Config
    attr_accessor :log_level, :drb_port, :vagrant_binary,
      :shutdown_vms, :skip_rollback, :start_server

    def self.default
      self.new
    end

    def configure
      yield(self)
      self
    end

    private

    def initialize
      @log_level = :warn
      @drb_port = 35672
      @vagrant_binary = 'vagrant'
      @shutdown_vms = false
      @skip_rollback = false
      @start_server = true
    end
  end
end
