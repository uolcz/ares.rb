module Ares
  class ResponseBuilder
    extend Utils::Buildable

    # Creates ares response from http response
    def self.from_response(response)
      builder = new
                    .body(response.body)
                    .parsed_body(response.parsed_response)
                    .http_response(response.response)

      return builder.error unless builder.success?
      builder.build!
    end

    attr_builder :http_response, :body, :parsed_body

    def initialize
      @http_response = nil
      @body = nil
      @parsed_body = nil
    end

    def success?
      @http_response.response.code == 200
    end

    def content
      @content ||= parse_body
    end

    def build!
      fail ResponseError, "#{@http_response.response.code} #{@http_response.response.message}" unless success?
      Response.new(@http_response.response, @body, content)
    end

    private

    def parse_body
      response_type = @parsed_body.at_xpath('/are:Ares_odpovedi/@odpoved_typ')
      parser = create_parser(response_type)

      content = @parsed_body.xpath('/are:Ares_odpovedi/are:Odpoved').map do |response|
        parser.parse(response)
      end
      (content.size == 1) ? content.first : content
    end

    def create_parser(response_type)
      response_module = Ares.types[response_type]
      parser_class = response_module.const_get(:Parser)
      parser_class.new
    end
  end
end
