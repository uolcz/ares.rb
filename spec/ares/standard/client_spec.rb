require 'spec_helper'

describe Ares::Standard::Client do
  let(:ico) { '27169278' }

  describe '::find_by' do
    it 'returns company' do
      result = described_class.find_by(ico: ico)
      expect(result).to be_a(Ares::Standard::Company)
    end
  end

  describe '#fetch' do
    it 'returns result set' do
      result_set = subject.fetch(ico: ico)
      expect(result_set).to be_a Ares::Response
    end

    it 'validate options'
  end
end