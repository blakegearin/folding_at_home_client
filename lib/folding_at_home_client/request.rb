# frozen_string_literal: true

module FoldingAtHomeClient
  class Request
    attr_reader :body, :response

    API_URL = "https://api.foldingathome.org"
    HEADERS = {
      "Accept" => "application/json",
    }

    def initialize(endpoint:, params: {})
      url = API_URL + endpoint
      @response = Faraday.get(url, params, HEADERS)

      parsed_response = JSON.parse(response.body, symbolize_names: true)
      @body = parsed_response.is_a?(Array) ? parsed_response : [parsed_response]
    end
  end
end
