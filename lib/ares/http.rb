# frozen_string_literal: true

module Ares
  module Http
    def get(url, params = {})
      response = HTTParty.get(url, query: params, timeout: Ares.timeout)
      response.body
    end

    def post(url, params = {})
      response = HTTParty.post(url, query: params, timeout: Ares.timeout)
      response.body
    end
  end
end
