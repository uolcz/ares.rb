module Ares
  module Responses
    class TextCode
      attr_reader :elem, :code, :text

      def initialize(elem, code, text)
        @elem = elem
        @code = code
        @text = text
      end

      def to_s
        "#{@code}: #{text}"
      end

      def inspect
        "#<TextCode(#{elem}) code=#{code} text=#{text}>"
      end
    end

    class Error < TextCode
      def error?; true end
    end
  end
end

require 'ares/responses/standard_response'