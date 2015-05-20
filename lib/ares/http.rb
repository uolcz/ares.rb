module Ares
  module Http
    def get(url, params = {})
      response = HTTParty.get(url, query: params)
      response.body
    end

    def post(url, params = {})
      response = HTTParty.post(url, query: params)
      response.body
    end
  end
end