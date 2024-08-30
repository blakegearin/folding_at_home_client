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
    Faraday::FlatParamsEncoder.decode(params)
  end
end

module FoldingAtHomeClient
  module Request
    API_URL = 'https://api.foldingathome.org'.freeze
    HEADERS = {
      'Accept' => 'application/json',
    }.freeze

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

    def request_unencoded(endpoint_and_params:, base_url: API_URL, format_response: true)
      response = connection(base_url:).get(endpoint_and_params)

      return format_response(response) if format_response

      response
    end

    def request(endpoint:, base_url: API_URL, format_response: true, params: {})
      full_url = base_url + endpoint
      response = Faraday.get(full_url, params, HEADERS)

      return format_response(response) if format_response

      response
    end

    def request_and_instantiate_objects(endpoint:, object_class:, params: {})
      request(endpoint:, params:).map do |hash|
        # require 'pry'
        # binding.pry
        # puts 'end of pry'
        object_class.new(**hash)
      end
    end

    # def request_and_instantiate_objects(endpoint:, object_class:, params: {})
    #   request(endpoint:, params:).map do |hash|
    #     object_class.new(*hash.values_at(*object_class.members))
    #   end
    # end
  end
end
