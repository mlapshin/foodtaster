require 'foodtaster/config'

describe Foodtaster::Config do
  context 'default options' do
    subject { described_class.new }

    its(:log_level)      { should == :info }
    its(:drb_port)       { should == 35672 }
    its(:vagrant_binary) { should == 'vagrant' }
    its(:shutdown_vms)   { should == false }
    its(:skip_rollback)  { should == false }
    its(:start_server)   { should == true }
  end

  context 'option overrides' do
    subject do
      described_class.new
    end

    before(:each) do
      subject.configure do |conf|
        conf.log_level = :debug
        conf.drb_port = 31415
        conf.vagrant_binary = '/some/vagrant'
        conf.shutdown_vms = true
        conf.skip_rollback = true
        conf.start_server = false
      end
    end

    its(:log_level)      { should == :debug }
    its(:drb_port)       { should == 31415 }
    its(:vagrant_binary) { should == '/some/vagrant' }
    its(:shutdown_vms)   { should == true }
    its(:skip_rollback)  { should == true }
    its(:start_server)   { should == false }
  end
end
