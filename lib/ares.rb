# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'active_support/core_ext/hash'

require 'ares/version'
require 'ares/errors'
require 'ares/logging'
require 'ares/http'

require 'ares/responses'
require 'ares/responses/base'
require 'ares/responses/standard'
require 'ares/responses/basic'

require 'ares/client/base'
require 'ares/client/standard'
require 'ares/client/basic'

require 'ico-validator'

module Ares
  # Default timeout for Ares requests
  DEFAULT_TIMEOUT = 5

  # Timout for Ares requests
  # Example:
  #   Ares.timeout = 4
  #   data = Ares.standard(ico: data.ico)
  mattr_accessor :timeout
  self.timeout = DEFAULT_TIMEOUT

  class << self
    include Ares::Logging

    # @see Client::Standard#call
    # @return [Responses::StandardResponse::Record]
    def standard(options)
      validate_ico_format(options[:ico])
      response = Client::Standard.call(options)
      raise ArgumentError, "Arguments #{options} are invalid" if response.error?

      response.record
    end

    # @see Client::Basic#call
    # @return [Responses::NoIdeaNow::Record]
    def basic(options)
      validate_ico_format(options[:ico])
      response = Client::Basic.call(options)
      raise ArgumentError, "Arguments #{options} are invalid" if response.error?

      response.record
    end

    private

    def validate_ico_format(ico)
      raise ArgumentError, "ICO '#{ico}' is invalid" unless IcoValidation.valid_ico?(ico)
    end
  end
end
