require 'spec_helper'

describe Foodtaster::Client do
  before(:each) { TestServer.start }
  after(:each)  { TestServer.stop }

  it 'should connect to server' do
    client = described_class.connect(TestServer::PORT)
    expect(client).not_to be(nil)
  end
end
