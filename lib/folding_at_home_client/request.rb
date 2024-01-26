# frozen_string_literal: true

module FoldingAtHomeClient
  module Request
    API_URL = "https://api.foldingathome.org"
    HEADERS = {
      "Accept" => "application/json",
    }

    def request(endpoint:, params: {})
      url = API_URL + endpoint
      response = Faraday.get(url, params, HEADERS)

      parsed_response = JSON.parse(response.body, symbolize_names: true)
      parsed_response.is_a?(Array) ? parsed_response : [parsed_response]
    end

    def request_and_instantiate_objects(endpoint:, params: {}, object_class:)
      request(endpoint: endpoint, params: params).map do |hash|
        object_class.new(**hash)
      end
    end
  end
end
