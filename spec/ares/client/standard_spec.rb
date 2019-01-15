require 'spec_helper'

describe Ares::Client::Standard do
  describe '.call' do
    it 'calls instance method' do
      client = double
      allow(Ares::Client::Standard).to receive(:new).and_return(client)
      expect(client).to receive(:call)
      Ares::Client::Standard.call({})
    end
  end

  describe '#call', :vcr do
    it 'correctly calls API getting back XML response for correct ico' do
      result = Ares::Client::Standard.call(ico: '27074358')

      expect(result).to be_a(Ares::Responses::Standard)
    end

    it 'correctly calls API getting back XML response for fake ico' do
      result = Ares::Client::Standard.call(ico: '00000001')

      expect(result).to be_a(Ares::Responses::Standard)
    end

    it 'correctly calls API getting back XML response for invalid ico' do
      result = Ares::Client::Standard.call(ico: '00000000')

      expect(result).to be_a(Ares::Responses::Standard)
    end
  end
end
