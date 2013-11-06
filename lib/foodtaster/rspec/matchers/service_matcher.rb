RSpec::Matchers.define :have_running_service do |service|
  match do |vm|
    result = vm.execute("status #{service}").stdout
    reuslt =~ /start\/running/
  end

  failure_message_for_should do |vm|
    "expected that #{vm.name} should have running service '#{service}'"
  end

  failure_message_for_should_not do |vm|
    "expected that #{vm.name} should not have running service '#{service}'"
  end

  description do
    "running service '#{service}'"
  end
end
