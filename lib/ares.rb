require 'httparty'
require 'nokogiri'
require 'ares/version'
require 'ares/errors'
require 'ares/logging'
require 'ares/client'

module Ares
  class << self
    include Ares::Logging

    # Returns standard client
    # @returns [Client::Standard]
    def client
      @client ||= Client.standard
    end

    # @see Client::Standard#call
    # @return [Responses::StandardResponse::Record]
    def standard(options)
      response = client.call(options)
      fail ArgumentError, "Arguments #{options} are invalid" if response.error?
      response.record
    end
  end
end
