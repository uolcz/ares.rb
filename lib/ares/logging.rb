# frozen_string_literal: true

require 'logger'

module Ares
  module Logging
    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
