require 'httparty'
require 'multi_xml'
require 'nokogiri'
require 'ares/version'
require 'ares/utils'
require 'ares/response'
require 'ares/response_builder'

require 'ares/standard/client'

module Ares
  MultiXml.parser = :nokogiri

  def self.types
    @types ||= {}
  end

  def self.find_by_identification(ico)
    Standard::Client.find_by(ico: ico)
  end
end
