module Ares
  module Responses
    class Base
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
        any?(&:error?)
      end

      def each(&block)
        @content.each(&block)
      end

      def to_xml
        @xml_document.to_xml
      end

      protected

      # rubocop:disable Metrics/AbcSize
      def assign_base_attributes(attributes)
        @time = attributes['odpoved_datum_cas'].to_s
        @count = attributes['odpoved_pocet'].to_s
        @type = attributes['odpoved_typ'].to_s # musi byt 'Standard'
        @output_format = (attributes['vystup_format'] || 'XML').to_s
        @xslt = (attributes['xslt'] || 'klient').to_s
        @validation_xslt = attributes['validation_XSLT'].to_s
        @id = attributes['Id'].to_s
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
