require 'spec_helper'

describe Foodtaster::Vm do
  let(:vm_name) { "vm" }
  let(:client) { double("client", vm_defined?: true) }
  subject { described_class.new(vm_name, client) }

  context 'invoking client methods' do
    it '#running?' do
      with_mocked(:vm_running?) do
        subject.running?
      end
    end

    it '#initial_snapshot_made?' do
      with_mocked(:initial_snapshot_made_on_vm?) do
        subject.initial_snapshot_made?
      end
    end

    it '#start!' do
      with_mocked(:start_vm) do
        subject.start!
      end
    end

    it '#make_initial_snapshot!' do
      with_mocked(:make_initial_snapshot_on_vm) do
        subject.make_initial_snapshot!
      end
    end

    it 'should start machine and make initial snapshot on prepare' do
      with_mocked(:vm_running?, :start_vm, :initial_snapshot_made_on_vm?, :make_initial_snapshot_on_vm) do
        subject.prepare
      end
    end

    it 'should check if machine is running and snapshot was made on prepared?' do
      with_mocked(:initial_snapshot_made_on_vm?) do
        allow(client).to receive(:vm_running?).and_return(true)
        subject.prepared?
        expect(client).to have_received(:vm_running?)
      end
    end

    it '#ip' do
      with_mocked(:vm_ip) do
        subject.ip
      end
    end

    it '#put_file' do
      with_mocked(:put_file_to_vm) do
        subject.put_file('/path', '/path')
      end
    end

    it '#get_file' do
      with_mocked(:get_file_from_vm) do
        subject.get_file('/path', '/path')
      end
    end

    it '#shutdown' do
      with_mocked(:shutdown_vm) do
        subject.shutdown
      end
    end

    it '#rollback' do
      with_mocked(:rollback_vm) do
        subject.rollback
      end
    end

    it '#execute' do
      with_mocked(:execute_command_on_vm) do
        subject.execute('echo 1')
      end
    end

    it '#execute_as' do
      with_mocked(:execute_command_on_vm) do
        subject.execute_as(:root, 'echo 1')
      end
    end

    it '#run_chef' do
      with_mocked(:run_chef_on_vm) do
        subject.run_chef({run_list: []})
      end
    end
  end
end
