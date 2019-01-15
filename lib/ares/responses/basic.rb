module Ares
  module Responses
    class Basic < Base
      def initialize(xml_document)
        @response_hash = Hash.from_xml(xml_document)
        @base_response = @response_hash.values.first

        assign_base_attributes(@base_response)

        @content = @base_response.map { |key, value| parse_elem(key, value) }.compact
      end

      def error?
        @content.any? { |e| e.is_a? Ares::Responses::Error }
      end

      def record
        response
      end

      def parse_elem(key, value)
        case key
        when 'Fault'
          Ares::Responses::Error.new(
            value,
            value['faultcode'].to_s,
            value['faultstring'].to_s
          )
        when 'Odpoved'
          Response.new(value)
        end
      end

      class Base
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/AbcSize
        def initialize(value)
          self.class.class_eval do
            if const_defined?(:ATTRIBUTES)
              attr_reader(*const_get(:ATTRIBUTES).map(&:parameterize))
            end
            if const_defined?(:COMPOSITE_ATTRIBUTES)
              attr_reader(*const_get(:COMPOSITE_ATTRIBUTES)
                .values.map(&:parameterize))
            end
          end

          return unless value

          if self.class.const_defined?(:ATTRIBUTES)
            self.class::ATTRIBUTES.each do |attribute|
              instance_variable_set("@#{attribute.parameterize}",
                                    value[attribute].presence)
            end
          end
          self.class::COMPOSITE_ATTRIBUTES.each do |class_name, key|
            full_class = "Ares::Responses::Basic::#{class_name}".constantize
            instance_variable_set("@#{key.parameterize}",
                                  full_class.new(value[key].presence))
          end if self.class.const_defined?(:COMPOSITE_ATTRIBUTES)
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength
      end

      class Response < Base
        ATTRIBUTES = %w[Pomocne_ID Vysledek_hledani Pocet_zaznamu].freeze

        COMPOSITE_ATTRIBUTES = {
          Introduction: 'Uvod',
          Record: 'Vypis_basic'
        }.freeze
      end

      class Record < Base
        ATTRIBUTES = %w[ICO Obchodni_firma Datum_vzniku Adresa_ARES Priznaky_subjektu
                        Kategorie_poctu_pracovniku].freeze

        COMPOSITE_ATTRIBUTES = {
          LegalForm: 'Pravni_forma',
          SendingAddress: 'Adresa_dorucovaci',
          Address: 'Adresa_ARES',
          CzNace: 'Nace',
          RegisteredInstitution: 'Registrace_RZP'
        }.freeze
      end

      class RegisteredInstitution < Base
        COMPOSITE_ATTRIBUTES = {
          BusinessOffice: 'Zivnostensky_urad',
          FinanceOffice: 'Financni_urad'
        }.freeze
      end

      class BusinessOffice < Base
        ATTRIBUTES = %w[Kod_ZU Nazev_ZU].freeze
      end

      class FinanceOffice < Base
        ATTRIBUTES = %w[Kod_FU Nazev_FU].freeze
      end

      class CzNace < Base
        ATTRIBUTES = %w[NACE].freeze
      end

      class SendingAddress < Base
        ATTRIBUTES = %w[zdroj Ulice_cislo PSC_obec].freeze
      end

      class Address < Base
        ATTRIBUTES = %w[zdroj ID_adresy Kod_statu Nazev_statu Nazev_okresu Nazev_obce
                        Nazev_casti_obce Nazev_mestske_casti Nazev_ulice Cislo_domovni
                        Typ_cislo_domovni Cislo_orientacni PSC].freeze

        COMPOSITE_ATTRIBUTES = {
          AddressUIR: 'Adresa_UIR'
        }.freeze
      end

      class AddressUIR < Base
        ATTRIBUTES = %w[Kod_oblasti Kod_kraje Kod_okresu Kod_obce Kod_pobvod Kod_sobvod
                        Kod_casti_obce Kod_mestske_casti PSC Kod_ulice Cislo_domovni
                        Typ_cislo_domovni Cislo_orientacni Kod_adresy Kod_objektu
                        PCD].freeze
      end

      class LegalForm < Base
        ATTRIBUTES = %w[zdroj Kod_PF Nazev_PF].freeze
      end

      class Introduction < Base
        ATTRIBUTES = %w[Nadpis Aktualizace_DB Datum_vypisu Cas_vypisu Typ_odkazu].freeze
      end
    end
  end
end
