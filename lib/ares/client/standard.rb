# frozen_string_literal: true

module Ares
  module Client
    class Standard < Base
      ENDPOINT = 'http://wwwinfo.mfcr.cz/cgi-bin/ares/darv_std.cgi'

      private

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
      def process_response(document)
        Ares::Responses::Standard.new(document)
      end
    end
  end
end
