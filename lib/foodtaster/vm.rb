require 'set'

module Foodtaster
  class Vm
    class ExecResult
      attr_reader :stderr
      attr_reader :stdout
      attr_reader :exit_status

      def initialize(hash)
        if hash
          @stderr = hash[:stderr].to_s.chomp
          @stdout = hash[:stdout].to_s.chomp
          @exit_status = hash[:exit_status]
        end
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
        find_by_name(vm_name) ||
          self.new(vm_name, Foodtaster::RSpecRun.current.client)
      end
    end

    def initialize(name, client)
      @name = name
      @client = client

      unless @client.vm_defined?(name)
        raise ArgumentError, "No machine defined with name #{name}"
      end

      self.class.register_vm(self)
    end

    def running?
      @client.vm_running?(self.name)
    end

    def initial_snapshot_made?
      @client.initial_snapshot_made_on_vm?(self.name)
    end

    def start!
      Foodtaster.logger.info "#{name}: Power on machine"
      @client.start_vm(self.name)
    end

    def make_initial_snapshot!
      Foodtaster.logger.info "#{name}: Creating initial snapshot"
      @client.make_initial_snapshot_on_vm(self.name)
    end

    def prepare
      Foodtaster.logger.info "#{name}: Preparing VM"

      unless running?
        self.start!
      end

      unless initial_snapshot_made?
        self.make_initial_snapshot!
      end
    end

    def prepared?
      self.running? && self.initial_snapshot_made?
    end

    def ip
      @client.vm_ip(name)
    end

    def put_file(local_fn, vm_fn)
      @client.put_file_to_vm(name, local_fn, vm_fn)
    end

    def get_file(vm_fn, local_fn)
      @client.get_file_from_vm(name, vm_fn, local_fn)
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
      exec_result = ExecResult.new(exec_result_hash)

      Foodtaster.logger.debug "#{name}: Finished with #{exec_result.exit_status}"
      Foodtaster.logger.debug "#{name}: STDOUT: #{exec_result.stdout}"
      Foodtaster.logger.debug "#{name}: STDERR: #{exec_result.stderr}"

      ExecResult.new(exec_result_hash)
    end

    def execute_as(user, command)
      cmd = %Q[sudo su -l #{user} -c "#{command}"]
      self.execute cmd
    end

    def run_chef(config)
      fail ArgumentError, "#{config.inspect} should have :run_list." unless config[:run_list]

      Foodtaster.logger.info "#{name}: Running Chef with Run List #{config[:run_list].join(', ')}"
      Foodtaster.logger.debug "#{name}: with JSON: #{config[:json].inspect}"
      @client.run_chef_on_vm(name, config)
      Foodtaster.logger.debug "#{name}: Chef Run finished"
    end
  end
end
