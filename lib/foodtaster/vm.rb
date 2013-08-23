module Foodtaster
  class Vm
    class ExecResult
      attr_reader :stderr
      attr_reader :stdout
      attr_reader :exit_status

      def initialize(hash)
        @stderr = hash[:stderr]
        @stdout = hash[:stdout]
        @exit_status = hash[:exit_status]
      end

      def successful?
        exit_status == 0
      end
    end

    attr_reader :name

    def initialize(name, client)
      @name = name
      @client = client

      unless @client.vm_defined?(name)
        raise ArgumentError, "No machine defined with name #{name}"
      end
    end

    def prepare
      Foodtaster.logger.info "#{name}: Preparing VM"
      @client.prepare_vm(name)
    end

    def rollback
      Foodtaster.logger.info "#{name}: Rollbacking VM"
      @client.rollback_vm(name)
    end

    def execute(command)
      Foodtaster.logger.debug "#{name}: Executing #{command}"
      exec_result_hash = @client.execute_command_on_vm(name, command)

      Foodtaster.logger.debug "#{name}: Finished with #{exec_result_hash[:exit_status]}"
      Foodtaster.logger.debug "#{name}: STDOUT: #{exec_result_hash[:stdout].chomp}"
      Foodtaster.logger.debug "#{name}: STDERR: #{exec_result_hash[:stderr].chomp}"

      ExecResult.new(exec_result_hash)
    end

    def run_chef(config)
      Foodtaster.logger.info "#{name}: Running Chef with Run List #{config[:run_list].join(', ')}"
      Foodtaster.logger.debug "#{name}: with JSON: #{config[:json].inspect}"
      @client.run_chef_on_vm(name, config)
      Foodtaster.logger.debug "#{name}: Chef Run finished"
    end
  end
end
