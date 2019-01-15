# frozen_string_literal: true

##
# From what I can quickly find I can only search by ICO
# at least for the time being...
#
module Ares
  module Client
    class Basic < Base
      ENDPOINT = 'https://wwwinfo.mfcr.cz/cgi-bin/ares/darv_bas.cgi'

      def call(opts)
        xml = get(self.class::ENDPOINT, opts.merge!(ver: '1.0.2'))
        process_response(xml)
      end

      private

      def process_response(document)
        Ares::Responses::Basic.new(document)
      end
    end
  end
end
