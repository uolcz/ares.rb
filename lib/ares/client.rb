require 'ares/http'
require 'ares/responses'

module Ares
  module Client
    autoload :Standard, 'ares/client/standard'

    class << self
      def standard
        Standard.new
      end
    end
  end
end