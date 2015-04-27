require 'spec_helper'

describe Ares do
  it 'has a version number' do
    expect(Ares::VERSION).not_to be nil
  end

  let(:ico) { '00000000' }

  context '#find_by_identification' do
    it 'returns result' do
      response = described_class.find_by_identification(ico)
      expect(response).to be_a(Ares::Standard::Company)
    end
  end

  context '#find_by_identification!' do
    it 'fails when no company found' do
      expect {
        described_class.find_by_identification!(ico)
      }.to raise_error(Ares::Standard::CompanyNotFound)
    end
  end
end
