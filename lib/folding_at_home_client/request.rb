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

    def connection(base_url: API_URL)
      Faraday.new(url: base_url) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter

        faraday.options.params_encoder = DoNotEncoder
      end
    end

    def format_response(response)
      parsed_response = JSON.parse(response.body, symbolize_names: true)
      parsed_response.is_a?(Array) ? parsed_response : [parsed_response]
    end

    def request_unencoded(base_url: API_URL, format_response: true, endpoint_and_params:)
      response = connection(base_url: base_url).get(endpoint_and_params)

      return format_response(response) if format_response

      response
    end

    def request(base_url: API_URL, format_response: true, endpoint:, params: {})
      full_url = base_url + endpoint
      response = Faraday.get(full_url, params, HEADERS)

      return format_response(response) if format_response

      response
    end

    def request_and_instantiate_objects(endpoint:, params: {}, object_class:)
      request(endpoint: endpoint, params: params).map do |hash|
        object_class.new(**hash)
      end
    end
  end
end
