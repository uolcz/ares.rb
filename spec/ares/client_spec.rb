require 'spec_helper'

describe Ares::Client do
  it '#standard' do
    expect(Ares::Client.standard).to be_instance_of Ares::Client::Standard
  end
end