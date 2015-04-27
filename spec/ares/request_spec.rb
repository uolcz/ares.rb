require 'spec_helper'

RSpec.describe Ares::Request do
  let(:http_method) { :get }
  let(:url)  { 'http://localhost/example.html' }
  let(:opts) { { str: 'test_ěšč+!', bool: true, int: 23 } }

  it 'create from options' do
    req = described_class.new(http_method, url, opts)
    expect(req.url).to eq 'http://localhost/example.html?bool=true&int=23&str=test_%C4%9B%C5%A1%C4%8D%2B%21'
  end

  describe '#uri' do
    subject { described_class.new(http_method, url, opts)}

    it 'returns uri object'do
      expect(subject.uri).to be_a(URI)
    end
  end
end