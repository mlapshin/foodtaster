require 'timeout'

# RSpec::Matchers.send(:include, VagrantHelper::Matchers::MatcherMethods)

RSpec::Matchers.define :have_running_process do |process|
  match do |vm|
    vm.execute("pgrep #{process}").successful?
  end

  failure_message_for_should do |vm|
    "expected that #{vm.name} should have running process '#{process}'"
  end

  failure_message_for_should_not do |vm|
    "expected that #{vm.name} should not have running process '#{process}'"
  end

  description do
    "have running process '#{process}'"
  end
end

RSpec::Matchers.define :have_package do |package|
  match do |vm|
    vm.execute("dpkg --status #{package}").successful?
  end

  failure_message_for_should do |vm|
    "expected that #{vm.name} should have installed package '#{package}'"
  end

  failure_message_for_should_not do |vm|
    "expected that #{vm.name} should not have installed package '#{package}'"
  end

  description do
    "have installed package '#{package}'"
  end
end

# TODO: I'm not sure if lsof is installed by default
RSpec::Matchers.define :listen_port do |port|
  match do |vm|
    ->{ vm.execute("sudo lsof -i :#{port.to_s} > /dev/null") }.should be_successful
  end

  failure_message_for_should do |vm|
    "expected that #{vm.name} should listen port '#{port}'"
  end

  failure_message_for_should_not do |vm|
    "expected that #{vm.name} should not listen port '#{port}'"
  end

  description do
    "listen port '#{port}'"
  end
end

RSpec::Matchers.define :have_group do |group|
  match do |vm|
    vm.execute("cat /etc/group | cut -d: -f1 | grep \"\\<#{group}\\>\"").successful?
  end

  failure_message_for_should do |vm|
    "expected that #{vm.name} should have group '#{group}'"
  end

  failure_message_for_should_not do |vm|
    "expected that #{vm.name} should not have group '#{group}'"
  end

  description do
    "have group '#{group}'"
  end
end

RSpec::Matchers.define :open_page do |address|
  match do |vm|
    result = vm.execute("wget #{address} -O /tmp/test-page").successful?
    vm.execute("rm /tmp/test-page")
    result
  end

  failure_message_for_should do |vm|
    "expected that #{vm.name} should open page '#{address}'"
  end

  failure_message_for_should_not do |vm|
    "expected that #{vm.name} should not open page '#{address}'"
  end

  description do
    "open page '#{address}'"
  end
end

def wait_until(_timeout = 5)
  begin
    timeout _timeout do
      until (result = yield)
        sleep 0.5
      end
      result
    end
  rescue Timeout::Error
    nil
  end
end

RSpec::Matchers.define :be_successful do |opts = {}|
  match do |command|
    if command.respond_to?(:call)
      wait_until(opts[:timeout] || 5) { command.call.successful? }
    else
      command.successful?
    end
  end
end

