# frozen_string_literal: false

class DoNotEncoder
  def self.encode(params)
    buffer = ''

    params.each do |key, value|
      buffer << "#{key}=#{value}&"
    end

    buffer.chop
  end

  def self.decode(params)
    return Faraday::FlatParamsEncoder.decode(params)
  end
end

module FoldingAtHomeClient
  module Request
    LOGGER = Logger.new(STDOUT)

    API_URL = "https://api.foldingathome.org"
    HEADERS = {
      "Accept" => "application/json",
    }

    def connection
      Faraday.new(url: API_URL) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter

        faraday.options.params_encoder = DoNotEncoder
      end
    end

    def format_response(response)
      parsed_response = JSON.parse(response.body, symbolize_names: true)
      parsed_response.is_a?(Array) ? parsed_response : [parsed_response]
    end

    def request_unencoded(endpoint_and_params:)
      response = connection.get(endpoint_and_params)

      format_response(response)
    end

    def request(endpoint:, params: {})
      url = API_URL + endpoint
      response = Faraday.get(url, params, HEADERS)

      format_response(response)
    end

    def request_and_instantiate_objects(endpoint:, params: {}, object_class:)
      request(endpoint: endpoint, params: params).map do |hash|
        object_class.new(**hash)
      end
    end
  end
end
