module Ares
  module Responses
    # Coresponds to <are:Ares_odpovedi> element.
    class StandardResponse
      include Enumerable

      # @!attribute [r] xml_document
      #   @return [String] XML Document returned by ares
      # @!attribute [r] time
      #   @return [String] Created at
      # @!attribute [r] count
      #   @return [String] Element count
      # @!attribute [r] type
      #   @return [String] 'Standard'
      # @!attribute [r] output_format
      #   @return [String] 'XML'
      # @!attribute [r] xslt
      #   @return [String] 'klient'
      # @!attribute [r] validation_xslt
      #   @return [String] Path to xsl document
      # @!attribute [r] id
      #   @return [String] ID
      attr_reader :xml_document, :time, :count, :type,
                  :output_format, :xslt, :validation_xslt, :id

      def initialize(xml_document)
        @xml_document = xml_document

        attributes = xml_document.root.attributes
        @time = attributes['odpoved_datum_cas'].to_s
        @count = attributes['odpoved_pocet'].to_s
        @type = attributes['odpoved_typ'].to_s # musí být 'Standard'
        @output_format = (attributes['vystup_format'] || 'XML').to_s
        @xslt = (attributes['xslt'] || 'klient').to_s
        @validation_xslt = attributes['validation_XSLT'].to_s
        @id = attributes['Id'].to_s

        @content = xml_document.root.children.map { |elem| parse_elem elem }.compact
      end

      # Returns response with found company
      # or nil if not found.
      #
      # @returns [Response, NilClass] response
      def response
        @content.first
      end

      def record
        response ? response.records.first : nil
      end

      def error?
        any? { |c| c.error? }
      end

      def each(&block)
        @content.each(&block)
      end

      def to_xml
        @xml_document.to_xml
      end

      private

      def parse_elem(elem)
        if elem.name == 'Fault'
          Ares::Responses::Error.new(
              elem,
              elem.at_xpath('./faultcode/text()').to_s,
              elem.at_xpath('./faultstring/text()').to_s
          )
        elsif elem.name == 'Odpoved'
          Response.new(elem)
        end
      end

      # <are:Odpoved> element
      class Response
        include Enumerable

        # @!attribute [r] id
        #   @return [Integer] id
        # @!attribute [r] count
        #   @return [Integer] Responses count
        # @!attribute [r] search_type
        #   @return [String] type of search:
        #     * FREE - searching by ico, if not found search by RC, if not found find by company's name
        #     * ICO, RC, OF - search by type, if not found searching ends.
        #     Searching type is shown in (Kod_shody_*) element.
        #
        # @!attribute [r] records
        #    @return [Record, Error] Found records
        attr_reader :id, :count, :search_type, :records

        # @param elem [Nokogiri::XML::Element]
        def initialize(elem)
          @id = @count = @search_type = nil
          @records = []
          elem.children.each { |child| parse_elem(child) }
        end

        def each(&block)
          @records.each(&block)
        end

        def error?
          @records.any? { |e| e.is_a? Responses::Error }
        end

        private

        # @param child [Nokogiri::XML::Element] Child element
        def parse_elem(child)
          case child.name
            when 'Pomocne_ID'
              @id = child.value
            when 'Pocet_zaznamu'
              @count = child.content.to_i
            when 'Typ_vyhledani'
              @search_type = child.content
            when 'Error'
              @records << Ares::Responses::Error.new(
                  child,
                  child.at_xpath('./Error_kod/text()').to_s,
                  child.at_xpath('./Error_text/text()').to_s
              )
            when 'Zaznam'
              @records << Record.new(child)
            when 'text'
              # do nothing
            else
              Ares.logger.warn("#{self}: Unexpected record #{child.name} at #{child.path}")
          end
        end
      end

      # <are:Zaznam> element
      class Record
        # @!attribute [r] match
        #    @return [Responses::TextCode] <are:Shoda_ICO/RC/OF> Code of matching register ('ICO', 'RC', 'OF')
        # @!attribute [r] search_by
        #    @return [String] <are:Vyhledano_dle> Register where record was found
        # @!attribute [r] register_type
        #    @return [String] <are:Typ_registru> Register code
        # @!attribute [r] creation_date
        #    @return [String] <are:Datum_vzniku> Date of creation
        # @!attribute [r] termination_date
        #    @return [String] <are:Datum_zaniku> Date of termination
        # @!attribute [r] validity_date
        #    @return [String] <are:Datum_platnosti>
        # @!attribute [r] legal_form
        #    @return [LegalForm] <are:Pravni_forma>
        # @!attribute [r] bussiness_name
        #    @return [String] <are:Obchodni_firma>
        # @!attribute [r] ico
        #    @return [String] <are:ICO>
        # @!attribute [r] identification
        #    @return [Identification] <are:Identifikace>
        # @!attribute [r] tax_office_code
        #    @return [String] <are:Kod_FU>
        # @!attribute [r] status_flags
        #    @return [Flags] <are:Priznaky_subjektu>
        attr_reader :match, :search_by, :register_type,
                    :creation_date, :termination_date, :validity_date,
                    :legal_form, :business_name, :ico, :identification,
                    :tax_office_code, :status_flags

        def initialize(elem)
          @match = get_match(elem)
          @search_by = elem.at_xpath('./are:Vyhledano_dle').content
          @register_type = TextCode.new('RegisterType',
                                        elem.at_xpath('./are:Typ_registru/dtt:Kod').content,
                                        elem.at_xpath('./are:Typ_registru/dtt:Text').content)
          date = elem.at_xpath('./are:Datum_vzniku')
          @creation_date = date ? Time.parse(date.content) : nil
          date = elem.at_xpath('./are:Datum_zaniku')
          @termination_date = date ? Time.parse(date.content) : nil
          date = elem.at_xpath('./are:Datum_platnosti')
          @validity_date = date ? Time.parse(date.content) : nil

          @legal_form = LegalForm.new(elem.at_xpath('./are:Pravni_forma'))
          @business_name = elem.at_xpath('./are:Obchodni_firma').content
          @ico = elem.at_xpath('./are:ICO').content
          id_elem = elem.at_xpath('./are:Identifikace')
          @identification = id_elem ? Identification.new(id_elem) : nil
          fu_code = elem.at_xpath('./are:Kod_FU')
          @tax_office_code = fu_code ? fu_code.content.to_i : nil
          flags = elem.at_xpath('./are:Priznaky_subjektu')
          @status_flags = flags ? StatusFlags.new(flags) : nil
        end

        # Returns company's address or nil if not specified
        #
        # @returns [AresAddress, NilClass] Address
        def address
          return unless identification
          identification.address
        end

        private

        def get_match(elem)
          name = code = text = nil
          if match = elem.at_xpath('./are:Shoda_ICO')
            name = 'Match ICO'
            code = match.at_xpath('./dtt:Kod').content
            text = match.at_xpath('./dtt:Text')
            text = (text ? text.content : nil)
          elsif match = elem.at_xpath('./are:Shoda_RC')
            name = 'Match RC'
            code = match.at_xpath('./dtt:Kod').content
            text = match.at_xpath('./dtt:Text')
            text = (text ? text.content : nil)
          elsif match = elem.at_xpath('./are:Shoda_OF')
            name = 'Match OF'
            code = match.at_xpath('./dtt:Kod').content
            text = match.at_xpath('./dtt:Text')
            text = (text ? text.content : nil)
          else
            return nil
          end

          TextCode.new(name, code, text)
        end
      end

      # <Pravni_forma> element
      class LegalForm
        # Typ ekonomického subjektu:
        # F-fyzická osoba tuzemská,
        # P-právnická osoba tuzemská,
        # X-zahraniční právnická osoba,
        # Z-zahraniční fyzická osoba,
        # O-fyzická osoba s organizační složkou
        # C-civilní osoba nepodnikající (v CEU)
        attr_reader :code, :name, :person, :text, :person_type

        def initialize(elem)
          code = elem.at_xpath('./dtt:Kod_PF')
          @code = code ? code.content.to_i : nil
          name = elem.at_xpath('./dtt:Nazev_PF')
          @name = name ? name.content : nil
          person = elem.at_xpath('./dtt:PF_osoba')
          @person = person ? person.content : nil
          @text = elem.xpath('./dtt:Text').map(&:content).join("\n")
          person_type = elem.at_xpath('./dtt:TZU_osoba')
          @person_type = person_type ? person_type.content : nil
        end
      end

      # <Identification> element
      class Identification
        # WTF: addr_puv? ares_answer_v_1.0.1.xsd:56 Adr_puv = dtt:adresa_ARES

        # @!attribute [r] person
        #    @return [Person] <are:Osoba>
        # @!attribute [r] address
        #    @return [AresAddress] <are:Adresa_ARES>
        # @!attribute [r] addr_puv
        #    @return [AresAddress] <are:Adr_puv>
        attr_reader :person, :address, :addr_puv

        def initialize(elem)
          person = elem.at_xpath('./are:Osoba')
          @person = person ? Person.new(person) : nil

          address = elem.at_xpath('./are:Adresa_ARES')
          @address = address ? AresAddress.new(address) : nil

          address = elem.at_xpath('./are:Adr_puv')
          @addr_puv = address ? AresAddress.new(address) : nil
        end
      end

      # <Osoba> element
      class Person
        attr_reader :title_before, :name, :last_name, :title_after, :birthdate, :personal_id_number,
                    :text, :address

        def initialize(elem)
          @title_before = text(elem, 'dtt:Titul_pred')
          @name = text(elem, 'dtt:Jmeno')
          @last_name = text(elem, 'dtt:Prijmeni')
          @title_after = text(elem, 'dtt:Titul_za')
          @birthdate = text(elem, 'dtt:Datum_narozeni')
          @personal_id_number = text(elem, 'dtt:Rodne_cislo')
          @text = text(elem, 'dtt:Osoba_textem')
          address = elem.at_xpath('./dtt:Bydliste')
          @address = address ? AresAddress.new(address) : nil
        end
      end

      # Ares address definition
      # ares_datatypes_v_1.0.4.xsd:788
      class AresAddress
        # Názvy:
        # uol ico: 27074358
        # en: http://wwwinfo.mfcr.cz/cgi-bin/ares/ares_sad.cgi?zdroj=0&adr=204437556&jazyk=en
        # cs: http://wwwinfo.mfcr.cz/cgi-bin/ares/ares_sad.cgi?zdroj=0&adr=204437556

        # @!attribute [r] id
        #   @return [Integer] Address ID (ID_adresy)
        # @!attribute [r] state_code
        #   @return [Integer] State code (Kod_statu)
        # @!attribute [r] state
        #   @return [Integer] State name (Nazev_statu)
        # @!attribute [r] territory
        #   @return [Integer] Territory (Nazev_oblasti)
        # @!attribute [r] region
        #   @return [Integer] Region (Nazev_kraje)
        # @!attribute [r] district
        #   @return [Integer] District (Nazev_okresu)
        # @!attribute [r] town
        #   @return [Integer] Town (Nazev_obce)
        # @!attribute [r] residential_area
        #   @return [Integer] Residential area (Nazev_casti_obce)
        # @!attribute [r] town_district
        #   @return [Integer] Town district (Nazev_mestske_casti)
        # @!attribute [r] street
        #   @return [Integer] Street (Nazev_ulice)
        # @!attribute [r] building_number
        #   @return [Integer] Building number (Cislo_domovni)
        # @!attribute [r] sequence_number
        #   @return [Integer] Sequence number (Cislo_orientacni)
        # @!attribute [r] land_registry_number
        #   @return [Integer] Land-registry number (Cislo_do_adresy)
        # @!attribute [r] postcode
        #   @return [Integer] postcode (PSC)
        # @!attribute [r] foreign_postcode
        #   @return [Integer] Foreign postcode (Zahr_PSC)
        attr_reader :id, :state_code, :state, :territory, :region, :district, :town, :residential_area,
                    :town_district, :street, :building_number, :sequence_number, :land_registry_number,
                    :postcode, :foreign_postcode

        # TODO: Dopřeložit

        # @!attribute [r] pobvod
        #   @return [Integer] (Nazev_pobvodu)
        attr_reader :pobvod

        def initialize(elem)
          @id = find(elem, 'dtt:ID_adresy')
          @state_code = find(elem, 'dtt:Kod_statu')
          @state = find(elem, 'dtt:Nazev_statu')
          @territory = find(elem, 'dtt:Nazev_oblasti')
          @region = find(elem, 'dtt:Nazev_kraje')
          @district = find(elem, 'dtt:Nazev_okresu')
          @town = find(elem, 'dtt:Nazev_obce')
          @pobvod = find(elem, 'dtt:Nazev_pobvodu')
          @residential_area = find(elem, 'dtt:Nazev_casti_obce')
          @town_district = find(elem, 'dtt:Nazev_mestske_casti')
          @street = find(elem, 'dtt:Nazev_ulice')
          @building_number = find(elem, 'dtt:Cislo_domovni')
          @sequence_number = find(elem, 'dtt:Cislo_orientacni')
          @land_registry_number = find(elem, 'dtt:Cislo_do_adresy')
          @postcode = find(elem, 'dtt:PSC')
          @foreign_postcode = find(elem, 'dtt:Zahr_PSC')
          @text = find(elem, 'dtt:Adresa_textem')
        end

        def inspect
          "#<AresAddress \"#{@id || @text}\""
        end

        # TODO: localize
        # @param lang [String] ('cz') Language
        def to_s(lang = 'cz')
          s = ''
          if street
            s << street
            s << " #{land_registry_number}" if land_registry_number
            if sequence_number || building_number
              s << ' '
              s << sequence_number if sequence_number
              s << '/' if building_number && sequence_number
              s << building_number if building_number
            end
            s << ", #{postcode} #{town}"
            if residential_area
              (town =~ /-/) ? s << ',' : s << '-' if town
              s << residential_area
            end
          else
            s << "#{postcode} #{town}"
            if residential_area
              s << '-' if town
              s << residential_area
            end
            s << " #{land_registry_number}" if land_registry_number
            if land_registry_number && building_number
              s << ' '
              s << sequence_number if sequence_number
              s << '/' if building_number && sequence_number
              s << building_number if building_number
            end
          end
          if lang == 'en'
            s << ", District: #{district}" if district
            s << ", State: #{state}" if state
          else
            s << ", okres: #{district}" if district
            s << ", stát: #{state}" if state
          end
          s
        end

        private

        def find(elem, path)
          res = elem.at_xpath("./#{path}")
          res.nil? ? nil : res.content
        end
      end

      # <Priznaky_subjektu>
      #
      # http://wwwinfo.mfcr.cz/ares/ares_xml_standard.html.en
      class StatusFlags
        attr_reader :flags

        def initialize(elem)
          flags = elem.at_xpath('./are:Priznaky_subjektu')
          @flags = flags ? flags.value : nil
        end

        def [](index)
          @flags[index]
        end

        def inspect
          "#<StatusFlags #{@flags}>"
        end
      end
    end
  end
end