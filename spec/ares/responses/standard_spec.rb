# frozen_string_literal: true

require 'spec_helper'

describe Ares::Responses::Standard do
  # @return [Nokogiri::XML::Document]
  def load_xml(name)
    xml_file = RSpec.root.join('fixtures', *name.split('/'))
    raise "Fixture file #{xml_file} not found." unless File.exist? xml_file

    Nokogiri::XML(xml_file)
  end

  def create(klass, xml_file, xpath = nil)
    xml = load_xml(xml_file)
    xml = xml.at_xpath(xpath) if xpath
    klass.new(xml)
  end

  subject { create(described_class, 'standard/response.xml') }

  it 'has valid attributes' do
    expect(subject).to have_attributes(
      time: '2015-05-18T17:26:35',
      count: '1',
      type: 'Standard',
      output_format: 'XML',
      xslt: 'klient',
      validation_xslt: '/ares/xml_doc/schemas/ares/ares_answer/v_1.0.0/ares_answer.xsl',
      id: 'ares'
    )
  end

  describe '#response' do
    it 'returns response' do
      expect(subject.response).to be_instance_of described_class::Response
    end
  end

  describe '#record' do
    it 'returns record' do
      expect(subject.record).to be_instance_of described_class::Record
    end

    it 'returns nil if record not found' do
      subject = create(described_class, 'standard/empty_response.xml')
      expect(subject.record).to be_nil
    end
  end

  describe '#error?' do
    it 'returns true when response contains error' do
      subject = create(described_class, 'standard/error_response.xml')
      expect(subject.error?).to be_truthy
    end

    it "returns false if response doesn't have error" do
      expect(subject.error?).to be_falsey
    end
  end

  describe Ares::Responses::Standard::Response do
    subject { create(described_class, 'standard/response.xml', '//are:Odpoved') }

    it {
      is_expected.to have_attributes(
        count: 1,
        search_type: 'FREE'
      )
    }

    it 'has record' do
      expect(subject).to all(be_a(Ares::Responses::Standard::Record))
    end

    describe '#error?' do
      it { is_expected.to_not be_error }

      it 'returns true if has errors' do
        subject = create(described_class, 'standard/error_response.xml', '//are:Odpoved')
        expect(subject).to be_error
      end
    end
  end

  describe Ares::Responses::Standard::Record do
    subject { create(described_class, 'standard/response.xml', '//are:Zaznam') }

    it {
      is_expected.to have_attributes(
        search_by: 'ICO',
        creation_date: Time.parse('2004-08-10'),
        validity_date: Time.parse('2015-05-18'),
        business_name: 'Účetnictví on-line, s.r.o.',
        ico: '27169278',
        tax_office_code: 5
      )
    }

    it 'has identification' do
      expect(subject.identification).to be_a(Ares::Responses::Standard::Identification)
    end
  end

  describe Ares::Responses::Standard::Identification do
    subject { create(described_class, 'standard/response.xml', '//are:Identifikace') }

    it 'has address' do
      expect(subject.address).to be_a(Ares::Responses::Standard::AresAddress)
    end
  end

  xdescribe Ares::Responses::Standard::Person do
  end

  describe Ares::Responses::Standard::AresAddress do
    subject { create(described_class, 'standard/response.xml', '//are:Adresa_ARES') }

    it {
      is_expected.to have_attributes(
        id: '204437556',
        state_code: '203',
        town: 'Praha',
        district: 'Hlavní město Praha',
        residential_area: 'Jinonice',
        town_district: 'Praha 5',
        street: 'Pekařská',
        building_number: '628',
        sequence_number: '14',
        postcode: '15500'
      )
    }
  end
end
