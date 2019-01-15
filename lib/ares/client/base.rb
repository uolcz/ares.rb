# frozen_string_literal: true

# require 'ares/responses/standard_response'

module Ares
  module Client
    class Base
      include Ares::Http

      def self.call(opts)
        new.call(opts)
      end

      def call(opts)
        xml = get(self.class::ENDPOINT, opts)
        document = Nokogiri::XML(xml)
        process_response(document)
      end

      protected

      def process_response(_document)
        raise NotImplementedError, "#{self.class} must implement process_response}"
      end
    end
  end
end
