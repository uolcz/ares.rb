require 'spec_helper'

describe Ares::Responses::Basic do
  describe 'parsed result', :vcr do
    it 'for correct ico' do
      result = Ares::Client::Basic.call(ico: '27074358')

      expect(result).to be_a(Ares::Responses::Basic)
      expect(result.record).to be_a(Ares::Responses::Basic::Response)
    end
  end

  describe '#record', :vcr do
    it 'for correct ico' do
      result = Ares::Client::Basic.call(ico: '27074358').record

      expect(result).to be_a(Ares::Responses::Basic::Response)
      expect(result.uvod).to be_a(Ares::Responses::Basic::Introduction)
      expect(result.vypis_basic).to be_a(Ares::Responses::Basic::Record)
      expect(result.vypis_basic.pravni_forma)
        .to be_a(Ares::Responses::Basic::LegalForm)
      expect(result.vypis_basic.adresa_dorucovaci)
        .to be_a(Ares::Responses::Basic::SendingAddress)
      expect(result.vypis_basic.adresa_ares).to be_a(Ares::Responses::Basic::Address)
      expect(result.vypis_basic.adresa_ares.adresa_uir)
        .to be_a(Ares::Responses::Basic::AddressUIR)
      expect(result.vypis_basic.nace).to be_a(Ares::Responses::Basic::CzNace)
      expect(result.vypis_basic.registrace_rzp)
        .to be_a(Ares::Responses::Basic::RegisteredInstitution)
      expect(result.vypis_basic.registrace_rzp.zivnostensky_urad)
        .to be_a(Ares::Responses::Basic::BusinessOffice)
      expect(result.vypis_basic.registrace_rzp.financni_urad)
        .to be_a(Ares::Responses::Basic::FinanceOffice)
      expect(result.vypis_basic.obchodni_firma).to eq('Asseco Central Europe, a.s.')
    end
  end
end
