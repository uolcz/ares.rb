require 'spec_helper'

describe Ares, :vcr do
  it 'has a version number' do
    expect(Ares::VERSION).not_to be nil
  end

  let(:valid_ico) { '27169278' }
  let(:nonexistent_ico) { '00000001' }
  let(:invalid_ico) { '00000000' }

  context '#standard' do
    it 'returns record' do
      response = Ares.standard(ico: valid_ico)
      expect(response).to be_a(Ares::Responses::StandardResponse::Record)
    end

    it 'contains correct data' do
      record = Ares.standard(ico: valid_ico)
      expect(record.business_name).to eq 'Účetnictví on-line, s.r.o.'
      expect(record.address.to_s).to eq 'Pekařská 14/628, 15500 Praha-Jinonice, okres: Hlavní město Praha'
      record.address.tap do |address|
        expect(address.street).to eq 'Pekařská'
        expect(address.sequence_number).to eq '14'
        expect(address.building_number).to eq '628'
        expect(address.postcode).to eq '15500'
        expect(address.town).to eq 'Praha'
        expect(address.residential_area).to eq 'Jinonice'
        expect(address.district).to eq 'Hlavní město Praha'
      end
    end

    it 'fails when wrong ico' do
      expect {
        Ares.standard(ico: invalid_ico)
      }.to raise_error ArgumentError, /ICO '.*' is invalid/
    end

    it 'returns nil if no records found' do
      expect(Ares.standard(ico: nonexistent_ico)).to be nil
    end
  end
end
