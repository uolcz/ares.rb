require 'httparty'
require 'nokogiri'

module Ares
  module Net
    class XMLClient
      include HTTParty

      # @param request [Ares::Request] request
      def initialize(request)
        @request = request
      end

      def call
        http_method = self.class.method(@request.http_method)
        http_method.call(@request.options)

      end
    end
  end
end