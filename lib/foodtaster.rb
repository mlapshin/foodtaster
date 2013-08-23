require 'foodtaster/config'
require 'foodtaster/rspec'

require 'logger'

module Foodtaster
  autoload :Client, 'foodtaster/client'
  autoload :Vm,     'foodtaster/vm'
  autoload :RSpecRun, 'foodtaster/rspec_run'

  class << self
    def logger
      @logger ||= Logger.new(STDOUT).tap do |log|
        log_level = ENV['FT_LOGLEVEL'] || self.config.log_level.to_s.upcase
        log.level = Logger.const_get(log_level)

        log.formatter = proc do |severity, datetime, progname, msg|
          "[FT #{severity}]: #{msg}\n"
        end
      end
    end
  end
end
