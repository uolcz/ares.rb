# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'ares'
require 'webmock/rspec'
require 'vcr'
require 'pry'

module ::RSpec
  module_function

  def root
    @spec_root ||= Pathname.new(__dir__)
  end
end

# WebMock.disable_net_connect!(:allow => 'coveralls.io')

VCR.configure do |c|
  c.configure_rspec_metadata!
  c.hook_into :webmock
  c.cassette_library_dir = 'spec/cassettes'
  c.ignore_hosts 'codeclimate.com'
end
