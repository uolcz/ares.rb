$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ares'
require 'webmock/rspec'
require 'vcr'

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

module ::RSpec
  module_function
  def root
    @spec_root ||= Pathname.new(__dir__)
  end
end

#WebMock.disable_net_connect!(:allow => 'coveralls.io')

VCR.configure do |c|
  c.configure_rspec_metadata!
  c.hook_into :webmock
  c.cassette_library_dir = 'spec/cassettes'
end
