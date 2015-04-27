require 'spec_helper'

describe Ares::ResponseBuilder do
  describe '::from_response' do
    let(:xml) do
      fail 'create xml'
    end
    # Mock response from Net::HTTP
    TestNetResponse = Struct.new(:code, :message)
    let(:net_response) { TestNetResponse.new(200, 'OK') }

    # Mock response from httparty
    TestResponse = Struct.new(:body, :parsed_response, :response)
    let(:http_response) do
      TestResponse.new(xml, Nokogiri::XML(xml), net_response)
    end

    it 'returns Response' do
      response = described_class.from_response(http_response)
      expect(response).to be_a Ares::Response
    end

    context 'bad response' do
      let(:net_response) { TestNetResponse.new(403, 'Forbidden') }

      it 'fails on wrong code' do
        expect {
          described_class.from_response(http_response)
        }.to raise_error(ResponseError, '403 Forbidden')
      end
    end
  end

  describe '#content' do
    let(:body) do
      Nokogiri::XML(<<-XML)
        <are:Ares_odpovedi odpoved_typ="Test" odpoved_pocet="1" xmlns:are="http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/ares/ares_answer/v_1.0.1">
          <are:Odpoved>test content</are:Odpoved>
        </are:Ares_odpovedi>
      XML
    end

    let(:body_multiple) do
      Nokogiri::XML(<<-XML)
        <are:Ares_odpovedi odpoved_typ="Test" odpoved_pocet="2" xmlns:are="http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/ares/ares_answer/v_1.0.1">
          <are:Odpoved>content1</are:Odpoved>
          <are:Odpoved>content2</are:Odpoved>
        </are:Ares_odpovedi>
      XML
    end

    it 'returns '

    context 'with test module' do
      module Ares::Test
        class Parser
          def parse(dom)
            dom.content
          end
        end
      end

      before do
        Ares.types['Test'] = Ares::Test
      end

      after do
        Ares.types.delete('Test')
      end


      it 'returns array' do
        subject.parsed_body(body_multiple)
        expect(subject.content).to contain_exactly('content1', 'content2')
      end

      it 'returns parsed content' do
        subject.parsed_body(body)
        expect(subject.content).to eq 'test content'
      end
    end
  end
end