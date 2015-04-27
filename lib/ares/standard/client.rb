module Ares
  module Standard
    # A standard query for an output of the entity's identification data
    class Client
      ARES_URI = 'http://wwwinfo.mfcr.cz/cgi-bin/ares/darv_std.cgi'

      # Search for standard entity's identification data.
      #
      # If query returns more entities, only first is used.
      #
      # @param (see #fetch)
      # @return [Ares::Standard::Company]
      def self.find_by(opts)
        response = new.fetch(opts)
        response.first
      end

      # Search for standard entity's identification data.
      #
      # @param (see #fetch)
      # @return [Ares::Response]
      def self.find_all(opts)
        new.fetch(opts)
      end

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
      def fetch(opts)
        response = HTTParty.get(ARES_URI, query: opts)
        ResponseBuilder.build(response)
      end
    end
  end
end
