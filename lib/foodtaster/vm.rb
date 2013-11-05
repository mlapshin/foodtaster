require 'set'

module Foodtaster
  class Vm
    class ExecResult
      attr_reader :stderr
      attr_reader :stdout
      attr_reader :exit_status

      def initialize(hash)
        @stderr = hash[:stderr].to_s
        @stdout = hash[:stdout].to_s
        @exit_status = hash[:exit_status]
      end

      def successful?
        exit_status == 0
      end
    end

    attr_reader :name

    @@vms = Set.new

    class << self
      def register_vm(vm)
        @@vms << vm
      end

      def shutdown_running_vms
        @@vms.each do |vm|
          vm.shutdown if vm.prepared?
        end
      end

      def find_by_name(vm_name)
        @@vms.find { |vm| vm.name == vm_name }
      end

      def get(vm_name)
        find_by_name(vm_name) || self.new(vm_name)
      end
    end

    def initialize(name)
      @name = name
      @client = Foodtaster::RSpecRun.current.client

      unless @client.vm_defined?(name)
        raise ArgumentError, "No machine defined with name #{name}"
      end

      self.class.register_vm(self)
    end

    def prepare
      Foodtaster.logger.info "#{name}: Preparing VM"
      @client.prepare_vm(name)
    end

    def prepared?
      @client.vm_prepared?(name)
    end

    def shutdown
      Foodtaster.logger.debug "#{name}: Shutting down VM"
      @client.shutdown_vm(name)
    end

    def rollback
      Foodtaster.logger.info "#{name}: Rolling back VM"
      @client.rollback_vm(name)
    end

    def execute(command)
      Foodtaster.logger.debug "#{name}: Executing #{command}"
      exec_result_hash = @client.execute_command_on_vm(name, command)

      Foodtaster.logger.debug "#{name}: Finished with #{exec_result_hash[:exit_status]}"
      Foodtaster.logger.debug "#{name}: STDOUT: #{exec_result_hash[:stdout].to_s.chomp}"
      Foodtaster.logger.debug "#{name}: STDERR: #{exec_result_hash[:stderr].to_s.chomp}"

      ExecResult.new(exec_result_hash)
    end

    def execute_as(user, command)
      cmd = %Q[sudo su -l #{user} -c "#{command}"]
      self.execute cmd
    end

    def run_chef(config)
      Foodtaster.logger.info "#{name}: Running Chef with Run List #{config[:run_list].join(', ')}"
      Foodtaster.logger.debug "#{name}: with JSON: #{config[:json].inspect}"
      @client.run_chef_on_vm(name, config)
      Foodtaster.logger.debug "#{name}: Chef Run finished"
    end
  end
end
