require 'httparty'
require 'nokogiri'
require 'ares/version'
require 'ares/errors'
require 'ares/logging'
require 'ares/client'
require 'ico-validator'

module Ares
  DEFAULT_TIMEOUT = 5

  @@timeout = DEFAULT_TIMEOUT
  mattr_accessor :timeout

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
      validate_ico_format(options[:ico])
      response = client.call(options)
      fail ArgumentError, "Arguments #{options} are invalid" if response.error?
      response.record
    end

    private

    def validate_ico_format(ico)
      unless IcoValidation.valid_ico?(ico)
        fail ArgumentError, "ICO '#{ico}' is invalid"
      end
    end
  end
end
