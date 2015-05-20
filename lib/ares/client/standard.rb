require 'ares/responses/standard_response'

module Ares
  module Client
    class Standard
      ENDPOINT = 'http://wwwinfo.mfcr.cz/cgi-bin/ares/darv_std.cgi'

      include Ares::Http

      # Search for standard entity's identification data
      #
      # @param [Hash] opts Options for searching as specified in http://wwwinfo.mfcr.cz/ares/ares_xml_standard.html.en
      # @option opts [String] :ico
      # @option opts [String] :obchodni_firma
      # @option opts [String] :nazev_obce
      # @option opts [String] :kod_pf
      # @option opts [String] :typ_registru
      # @option opts [Integer] :xml (0) Type of xml output.
      # @option opts [String] :jazyk ('cz') Text of html pages [cz, en]
      # @option opts [Integer] :max_pocet (10)
      # @option opts [Integer] :aktivni (0) [0, 1]
      # @option opts [Integer] :adr_puv [0, 1]
      # @option opts [String] :typ_vyhledani ('free') Selection priority [free, ico, of]
      # @option opts [Integer] :diakritika (1) [0, 1]
      # @option opts [String] :czk (iso) Encoding [iso, utf]
      # @returns [Ares::Responses::StandardResponse]
      def call(opts)
        xml = get(ENDPOINT, opts)
        document = Nokogiri::XML(xml)
        Ares::Responses::StandardResponse.new(document)
      end
    end
  end
end