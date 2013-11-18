require 'foodtaster'
require 'support/test_server'

def with_mocked(*method_names)
  method_names.each do |method_name|
    allow(client).to receive(method_name)
  end
  yield
  method_names.each do |method_name|
    expect(client).to have_received(method_name)
  end
end
